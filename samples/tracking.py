"""Sample code for tracking."""

import random

import mlflow


def run_experiment():
    # parameters
    n = random.random()
    mlflow.log_param("n", n)

    # metrics
    for i in range(100):
        value = n / (i + 1)

        mlflow.log_metric("metric1", value=value, step=i)


mlflow_uri = "http://localhost:5000"
mlflow.set_tracking_uri(mlflow_uri)

print(f"{mlflow.get_tracking_uri()}")

exp_id = mlflow.set_experiment("tracking_sample1")

with mlflow.start_run():
    run_experiment()
