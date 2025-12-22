# DAD MQTT-IoT Anomaly Detection

This project trains supervised machine learning models on the DAD dataset to detect anomalies in MQTT-based IoT traffic. It provides a full training pipeline with SMOTE balancing, recursive feature elimination (RFE), model comparison, and a lightweight Flask UI/REST API for real-time predictions.

## Project layout
- `anomaly_detection/` – data loading, preprocessing, and training utilities.
- `train.py` – CLI entry point to train and evaluate models.
- `app.py` – Flask application that serves predictions and a simple web UI.
- `templates/` & `static/` – assets for the Flask UI.
- `artifacts/` – generated models, metrics, and feature manifest (created after training).
- `requirements.txt` – Python dependencies.

## Requirements
- Python 3.8+
- DAD dataset CSV or PCAP export. Download from [dad-repository/dad](https://github.com/dad-repository/dad) and point the CLI to the file.

Install dependencies:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Training
Train all models with stratified 5-fold CV (ROC-AUC scoring), SMOTE, and RFE selecting the top 12 features:

```bash
python train.py --data path/to/dad.csv --label-column label --time-column timestamp
```

Key options:
- `--drop-columns` – remove id/text columns before training.
- `--test-size` – hold-out fraction (default 0.2).
- `--feature-count` – number of features kept by RFE (default 12).
- `--artifacts-dir` – directory to store the trained pipeline, metrics, manifest, and optional feature-importance plot.

Outputs (written to `artifacts/` by default):
- `best_model.joblib` – full preprocessing + SMOTE + RFE + classifier pipeline.
- `metrics.json` – per-model ROC-AUC/F1/accuracy/precision/recall.
- `feature_manifest.json` – columns used for preprocessing and inference.
- `feature_importance.png` – top-ranked features for tree-based models (when available).

## Running the Flask API/UI
After training, start the server:

```bash
python app.py
```

- Web UI: http://localhost:8000 – submit JSON payloads for prediction.
- REST: `POST /predict` with a JSON object or list of objects containing the expected features.
- Health: `GET /health`

Example payload:

```json
[
  {
    "frame_len": 128,
    "protocol": "tcp",
    "ip_src": "192.168.1.10",
    "ip_dst": "192.168.1.20",
    "src_port": 1883,
    "dst_port": 55342,
    "hour_sin": 0.5,
    "hour_cos": 0.5
  }
]
```

If you include the original time column (e.g., `timestamp`), the API will automatically apply cyclical encoding during inference.

## Notes
- The pipeline uses SMOTE to handle class imbalance and RFE (DecisionTree estimator) to retain the top N features.
- Candidate models: Logistic Regression, Bernoulli Naive Bayes, Random Forest, AdaBoost, and Linear SVM.
- Metrics: Accuracy, Precision, Recall, F1, and ROC-AUC (for models exposing scores).
- The full preprocessing chain is saved inside the joblib artifact, so the Flask app only needs the raw feature payload.
