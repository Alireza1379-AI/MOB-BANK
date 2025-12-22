from __future__ import annotations

from datetime import datetime
from pathlib import Path
from typing import Iterable, Optional, Sequence

import numpy as np
import pandas as pd
from scapy.all import rdpcap
from scapy.layers.inet import IP, TCP, UDP


TIME_CANDIDATES: Sequence[str] = (
    "timestamp",
    "frame_time",
    "frame_time_relative",
    "time",
    "datetime",
)


def standardize_columns(df: pd.DataFrame) -> pd.DataFrame:
    renamed = {col: col.strip().lower().replace(" ", "_") for col in df.columns}
    return df.rename(columns=renamed)


def add_time_features(df: pd.DataFrame, time_column: str) -> pd.DataFrame:
    frame = df.copy()
    if time_column not in frame.columns:
        raise KeyError(f"Time column '{time_column}' not found in dataset")

    frame[time_column] = pd.to_datetime(frame[time_column], errors="coerce")
    frame = frame.dropna(subset=[time_column])
    hours = frame[time_column].dt.hour + frame[time_column].dt.minute / 60.0
    frame["hour_sin"] = np.sin(2 * np.pi * hours / 24)
    frame["hour_cos"] = np.cos(2 * np.pi * hours / 24)
    frame = frame.drop(columns=[time_column])
    return frame


def _infer_time_column(columns: Iterable[str]) -> Optional[str]:
    for candidate in TIME_CANDIDATES:
        if candidate.lower() in columns:
            return candidate.lower()
    return None


def pcap_to_dataframe(path: Path) -> pd.DataFrame:
    packets = rdpcap(str(path))
    rows = []
    for packet in packets:
        timestamp = float(packet.time)
        length = len(packet)
        src = packet[IP].src if IP in packet else None
        dst = packet[IP].dst if IP in packet else None
        proto = "tcp" if TCP in packet else "udp" if UDP in packet else packet.name.lower()
        sport = packet[TCP].sport if TCP in packet else packet[UDP].sport if UDP in packet else None
        dport = packet[TCP].dport if TCP in packet else packet[UDP].dport if UDP in packet else None

        rows.append(
            {
                "timestamp": datetime.fromtimestamp(timestamp),
                "frame_len": length,
                "ip_src": src,
                "ip_dst": dst,
                "protocol": proto,
                "src_port": sport,
                "dst_port": dport,
            }
        )

    return pd.DataFrame(rows)


def load_dataset(path: str | Path, time_column: Optional[str] = None, label_column: str = "label") -> pd.DataFrame:
    raw_path = str(path)
    is_remote = raw_path.startswith(("http://", "https://"))
    dataset_path = Path(path) if not is_remote else None
    if dataset_path and not dataset_path.exists():
        raise FileNotFoundError(f"Dataset not found at {dataset_path}")

    label_column = label_column.lower()
    time_column = time_column.lower() if time_column else None

    if dataset_path and dataset_path.suffix.lower() in {".pcap", ".pcapng"}:
        df = pcap_to_dataframe(dataset_path)
    else:
        df = pd.read_csv(raw_path)

    df = standardize_columns(df)
    if label_column not in df.columns:
        raise KeyError(f"Label column '{label_column}' was not found in the dataset")

    chosen_time_column = time_column if time_column else _infer_time_column(df.columns)
    if chosen_time_column:
        df = add_time_features(df, chosen_time_column)

    return df
