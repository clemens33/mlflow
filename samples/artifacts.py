"""Artifact logging example."""

import mlflow

# Set the tracking URI
mlflow_uri = "http://localhost:5000"
mlflow.set_tracking_uri(mlflow_uri)

print(f"Tracking at: {mlflow.get_tracking_uri()}")

mlflow.set_experiment("artifact_sample1")

with mlflow.start_run():
    mlflow.log_artifact(__file__)
