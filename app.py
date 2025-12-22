from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List

import joblib
import pandas as pd
from flask import Flask, jsonify, render_template, request

from anomaly_detection.data import add_time_features, standardize_columns
from anomaly_detection.pipeline import predict_with_model

APP_ROOT = Path(__file__).parent
MODEL_PATH = APP_ROOT / "artifacts" / "best_model.joblib"
MANIFEST_PATH = APP_ROOT / "artifacts" / "feature_manifest.json"


def load_model_and_manifest():
    if not MODEL_PATH.exists() or not MANIFEST_PATH.exists():
        return None, None

    model = joblib.load(MODEL_PATH)
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    return model, manifest


def prepare_payload(rows: List[Dict[str, Any]], manifest: Dict[str, Any]) -> pd.DataFrame:
    frame = pd.DataFrame(rows)
    frame = standardize_columns(frame)

    time_column = manifest.get("time_column")
    if time_column and time_column in frame.columns:
        frame = add_time_features(frame, time_column)

    expected_columns = set(manifest.get("categorical_features", []) + manifest.get("numeric_features", []))
    for column in expected_columns:
        if column not in frame.columns:
            frame[column] = None

    return frame


app = Flask(__name__)
model, manifest = load_model_and_manifest()


@app.get("/")
def index():
    return render_template("index.html", manifest=manifest, ready=model is not None)


@app.post("/predict")
def predict():
    if model is None or manifest is None:
        return jsonify({"error": "Model not loaded. Train the pipeline first."}), 503

    payload = request.get_json(silent=True)
    if payload is None:
        return jsonify({"error": "Expected JSON payload"}), 400

    rows = payload if isinstance(payload, list) else [payload]
    data = prepare_payload(rows, manifest)
    predictions = predict_with_model(model, data)
    return jsonify(predictions)


@app.get("/health")
def health():
    return {"status": "ok", "model_loaded": MODEL_PATH.exists()}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
