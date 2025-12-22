from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

import json
import joblib
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from imblearn.over_sampling import SMOTE
from imblearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import AdaBoostClassifier, RandomForestClassifier
from sklearn.feature_selection import RFE
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score, roc_auc_score
from sklearn.model_selection import GridSearchCV, StratifiedKFold
from sklearn.naive_bayes import BernoulliNB
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier

RANDOM_STATE = 42


@dataclass
class TrainingResult:
    name: str
    best_params: Dict[str, Any]
    cv_score: float
    metrics: Dict[str, float]


def _encode_labels(labels: pd.Series) -> pd.Series:
    if labels.dtype.kind in {"i", "u"}:
        return labels.astype(int)

    normalized = labels.astype(str).str.lower().str.strip()
    positive_aliases = {"anomaly", "attack", "malicious", "1", "true", "yes", "abnormal"}
    binary = normalized.isin(positive_aliases).astype(int)
    if binary.nunique() == 1:
        unique = sorted(normalized.unique())
        mapping = {value: idx for idx, value in enumerate(unique)}
        return normalized.map(mapping)
    return binary


def prepare_features(
    df: pd.DataFrame,
    label_column: str,
    drop_columns: Optional[Iterable[str]] = None,
) -> Tuple[pd.DataFrame, pd.Series, List[str], List[str]]:
    if label_column not in df.columns:
        raise KeyError(f"Label column '{label_column}' not found in dataframe")

    features = df.drop(columns=[label_column])
    if drop_columns:
        features = features.drop(columns=list(drop_columns), errors="ignore")

    categorical_features = list(features.select_dtypes(include=["object", "string", "category"]).columns)
    numeric_features = [col for col in features.columns if col not in categorical_features]

    y = _encode_labels(df[label_column])
    return features, y, categorical_features, numeric_features


def build_preprocessor(categorical_features: List[str], numeric_features: List[str]) -> ColumnTransformer:
    numeric_pipeline = Pipeline(
        steps=[
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler", StandardScaler()),
        ]
    )
    categorical_pipeline = Pipeline(
        steps=[
            ("imputer", SimpleImputer(strategy="most_frequent")),
            (
                "encoder",
                OneHotEncoder(handle_unknown="ignore", sparse_output=True),
            ),
        ]
    )

    return ColumnTransformer(
        transformers=[
            ("categorical", categorical_pipeline, categorical_features),
            ("numeric", numeric_pipeline, numeric_features),
        ],
        remainder="drop",
    )


def build_model_specs(
    preprocessor: ColumnTransformer,
    n_features_to_select: int = 12,
) -> Dict[str, Tuple[Pipeline, Dict[str, List[Any]]]]:
    selector = RFE(
        estimator=DecisionTreeClassifier(random_state=RANDOM_STATE),
        n_features_to_select=n_features_to_select,
    )
    smote = SMOTE(random_state=RANDOM_STATE)

    base_steps = [
        ("preprocessor", preprocessor),
        ("smote", smote),
        ("rfe", selector),
    ]

    specs: Dict[str, Tuple[Pipeline, Dict[str, List[Any]]]] = {}

    specs["logistic_regression"] = (
        Pipeline(
            steps=base_steps
            + [
                (
                    "classifier",
                    LogisticRegression(max_iter=2000, n_jobs=-1),
                )
            ]
        ),
        {
            "classifier__C": [0.1, 1, 10],
            "classifier__penalty": ["l2"],
            "classifier__solver": ["lbfgs", "liblinear"],
        },
    )

    specs["bernoulli_nb"] = (
        Pipeline(steps=base_steps + [("classifier", BernoulliNB())]),
        {"classifier__alpha": [0.1, 0.5, 1.0]},
    )

    specs["random_forest"] = (
        Pipeline(steps=base_steps + [("classifier", RandomForestClassifier(random_state=RANDOM_STATE))]),
        {
            "classifier__n_estimators": [200, 400],
            "classifier__max_depth": [None, 10, 20],
        },
    )

    specs["adaboost"] = (
        Pipeline(steps=base_steps + [("classifier", AdaBoostClassifier(random_state=RANDOM_STATE))]),
        {
            "classifier__n_estimators": [100, 200],
            "classifier__learning_rate": [0.5, 1.0, 1.5],
        },
    )

    specs["linear_svm"] = (
        Pipeline(
            steps=base_steps
            + [
                (
                    "classifier",
                    SVC(kernel="linear", probability=True, random_state=RANDOM_STATE),
                )
            ]
        ),
        {"classifier__C": [0.5, 1, 2]},
    )

    return specs


def _probability_scores(model: Any, features: pd.DataFrame) -> Optional[np.ndarray]:
    if hasattr(model, "predict_proba"):
        probabilities = model.predict_proba(features)
        if probabilities.shape[1] > 1:
            return probabilities[:, 1]
        return probabilities.ravel()

    if hasattr(model, "decision_function"):
        raw_scores = model.decision_function(features)
        if raw_scores.ndim > 1:
            raw_scores = raw_scores[:, 1]
        shifted = raw_scores - raw_scores.min()
        return shifted / (shifted.max() + 1e-9)

    return None


def _evaluate_predictions(y_true: pd.Series, y_pred: np.ndarray, y_score: Optional[np.ndarray]) -> Dict[str, float]:
    metrics = {
        "accuracy": accuracy_score(y_true, y_pred),
        "precision": precision_score(y_true, y_pred, zero_division=0),
        "recall": recall_score(y_true, y_pred, zero_division=0),
        "f1": f1_score(y_true, y_pred, zero_division=0),
    }
    if y_score is not None:
        metrics["roc_auc"] = roc_auc_score(y_true, y_score)
    return metrics


def train_models(
    X_train: pd.DataFrame,
    y_train: pd.Series,
    X_test: pd.DataFrame,
    y_test: pd.Series,
    model_specs: Dict[str, Tuple[Pipeline, Dict[str, List[Any]]]],
) -> Tuple[List[TrainingResult], Pipeline, str]:
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=RANDOM_STATE)
    results: List[TrainingResult] = []
    best_model: Optional[Pipeline] = None
    best_name = ""
    best_score = -np.inf

    for name, (pipeline, param_grid) in model_specs.items():
        search = GridSearchCV(
            estimator=pipeline,
            param_grid=param_grid,
            scoring="roc_auc",
            n_jobs=-1,
            cv=cv,
            verbose=0,
        )
        search.fit(X_train, y_train)

        y_pred = search.predict(X_test)
        y_score = _probability_scores(search, X_test)
        metrics = _evaluate_predictions(y_test, y_pred, y_score)

        results.append(
            TrainingResult(
                name=name,
                best_params=search.best_params_,
                cv_score=search.best_score_,
                metrics=metrics,
            )
        )

        if metrics["f1"] > best_score:
            best_score = metrics["f1"]
            best_model = search.best_estimator_
            best_name = name

    if best_model is None:
        raise RuntimeError("No model was trained successfully")

    return results, best_model, best_name


def feature_names_from_model(model: Pipeline) -> List[str]:
    preprocessor: ColumnTransformer = model.named_steps["preprocessor"]
    transformer_features = list(preprocessor.get_feature_names_out())
    selector: RFE = model.named_steps["rfe"]
    if len(selector.support_) != len(transformer_features):
        return transformer_features
    return [name for name, keep in zip(transformer_features, selector.support_) if keep]


def plot_feature_importances(model: Pipeline, output_path: Path) -> Optional[Path]:
    classifier = model.named_steps["classifier"]
    if not hasattr(classifier, "feature_importances_"):
        return None

    feature_names = feature_names_from_model(model)
    importances = classifier.feature_importances_
    sorted_idx = np.argsort(importances)[::-1][: min(20, len(importances))]
    plt.figure(figsize=(10, 6))
    sns.barplot(x=importances[sorted_idx], y=[feature_names[i] for i in sorted_idx], palette="viridis")
    plt.title("Top Feature Importances")
    plt.xlabel("Importance")
    plt.tight_layout()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(output_path)
    plt.close()
    return output_path


def save_artifacts(
    best_model: Pipeline,
    results: List[TrainingResult],
    manifest: Dict[str, Any],
    output_dir: Path = Path("artifacts"),
) -> Dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    model_path = output_dir / "best_model.joblib"
    metrics_path = output_dir / "metrics.json"
    manifest_path = output_dir / "feature_manifest.json"

    joblib.dump(best_model, model_path)
    with metrics_path.open("w", encoding="utf-8") as fp:
        json.dump([result.__dict__ for result in results], fp, indent=2)
    with manifest_path.open("w", encoding="utf-8") as fp:
        json.dump(manifest, fp, indent=2)

    plot_path = plot_feature_importances(best_model, output_dir / "feature_importance.png")
    paths = {"model": model_path, "metrics": metrics_path, "manifest": manifest_path}
    if plot_path:
        paths["feature_importance"] = plot_path
    return paths


def predict_with_model(model: Pipeline, data: pd.DataFrame) -> Dict[str, Any]:
    predictions = model.predict(data)
    scores = _probability_scores(model, data)
    return {
        "predictions": predictions.tolist(),
        "scores": scores.tolist() if scores is not None else None,
    }


def build_manifest(
    categorical_features: List[str],
    numeric_features: List[str],
    selected_features: List[str],
    label_column: str,
    time_column: Optional[str],
) -> Dict[str, Any]:
    return {
        "categorical_features": categorical_features,
        "numeric_features": numeric_features,
        "selected_features": selected_features,
        "label_column": label_column,
        "time_column": time_column,
    }
