## Project Overview

This repository now focuses on a Python-based anomaly detection pipeline for the DAD MQTT-IoT dataset. It includes:
- Data loading utilities for CSV/PCAP traffic captures.
- Feature engineering (cyclical time encoding) and preprocessing (imputation, scaling/encoding).
- SMOTE + RFE + supervised model training (Logistic Regression, Bernoulli NB, Random Forest, AdaBoost, Linear SVM).
- A Flask UI/REST API for serving predictions with the trained pipeline.

## Development
- Python 3.8+ is required.
- Install dependencies from `requirements.txt` (recommend using a virtual environment).
- Artifacts (model, metrics, manifest) are written to the `artifacts/` directory by default.

### Key Entrypoints
- `train.py` — trains and evaluates the models. Supports CSV or PCAP inputs.
- `app.py` — Flask server exposing `GET /` (UI) and `POST /predict` (JSON inference).
- `anomaly_detection/` — shared modules for data handling and model training.

## Coding Conventions & Notes
- Keep preprocessing inside pipelines where possible to ensure parity between training and inference.
- Avoid broad try/except around imports; fail loudly if dependencies are missing.
- Prefer clear, typed helper functions and dataclasses for passing structured results.
- Save reproducible artifacts (joblib model, metrics.json, feature_manifest.json) after training.

## Testing
- There is no dedicated test suite yet. Run lightweight smoke commands (e.g., `python train.py --help`) after edits.

## Documentation
- Update `README.md` when changing CLI flags, model defaults, or inference behavior so users can retrain and serve predictions confidently.
