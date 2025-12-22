from __future__ import annotations

import argparse
from pathlib import Path

from sklearn.model_selection import train_test_split

from anomaly_detection.data import load_dataset
from anomaly_detection.pipeline import (
    RANDOM_STATE,
    build_manifest,
    build_model_specs,
    build_preprocessor,
    feature_names_from_model,
    prepare_features,
    save_artifacts,
    train_models,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Train supervised models for MQTT-IoT anomaly detection using the DAD dataset.",
    )
    parser.add_argument(
        "--data",
        required=True,
        help="Path to the CSV or PCAP dataset (e.g., dad.csv or capture.pcap).",
    )
    parser.add_argument(
        "--label-column",
        default="label",
        help="Name of the column containing the ground-truth label (default: label).",
    )
    parser.add_argument(
        "--time-column",
        default=None,
        help="Optional time column to encode as cyclical hour features (e.g., timestamp).",
    )
    parser.add_argument(
        "--drop-columns",
        nargs="*",
        default=[],
        help="Columns to drop before training (ids or unneeded text fields).",
    )
    parser.add_argument(
        "--test-size",
        type=float,
        default=0.2,
        help="Fraction of the dataset to reserve for testing (default: 0.2).",
    )
    parser.add_argument(
        "--feature-count",
        type=int,
        default=12,
        help="Number of features to keep via RFE (default: 12).",
    )
    parser.add_argument(
        "--artifacts-dir",
        default="artifacts",
        help="Directory to write trained model and reports (default: artifacts).",
    )
    return parser.parse_args()


def describe_results(results) -> str:
    lines = ["Model performance (sorted by F1):"]
    ordered = sorted(results, key=lambda r: r.metrics.get("f1", 0), reverse=True)
    for result in ordered:
        metrics = ", ".join(
            f"{name}={value:.3f}" for name, value in result.metrics.items()
        )
        lines.append(f"- {result.name}: {metrics} | best params: {result.best_params}")
    return "\n".join(lines)


def main() -> None:
    args = parse_args()
    data_path = Path(args.data)
    label_column = args.label_column.lower()
    time_column = args.time_column.lower() if args.time_column else None
    df = load_dataset(data_path, time_column=time_column, label_column=label_column)

    X, y, categorical_features, numeric_features = prepare_features(
        df, label_column=label_column, drop_columns=args.drop_columns
    )

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=args.test_size,
        random_state=RANDOM_STATE,
        stratify=y,
    )

    preprocessor = build_preprocessor(categorical_features, numeric_features)
    model_specs = build_model_specs(preprocessor, n_features_to_select=args.feature_count)
    results, best_model, best_name = train_models(
        X_train, y_train, X_test, y_test, model_specs
    )

    selected_features = feature_names_from_model(best_model)
    manifest = build_manifest(
        categorical_features=categorical_features,
        numeric_features=numeric_features,
        selected_features=selected_features,
        label_column=label_column,
        time_column=time_column,
    )

    paths = save_artifacts(
        best_model=best_model,
        results=results,
        manifest=manifest,
        output_dir=Path(args.artifacts_dir),
    )

    summary = describe_results(results)
    print(summary)
    print("\nBest model:", best_name)
    print("Artifacts written to:")
    for key, path in paths.items():
        print(f"- {key}: {path}")


if __name__ == "__main__":
    main()
