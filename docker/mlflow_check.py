"""MLflow check."""

import argparse
import mlflow
import socket
import sys


def check(tracking_uri: str, check_artifact_store: bool):
    """MLflow check."""

    try:
        mlflow.set_tracking_uri(tracking_uri)

        container_id = socket.gethostname()
        experiment_name = f"check-{container_id}"
        experiment = mlflow.set_experiment(experiment_name)

        # Create experiment / check
        with mlflow.start_run():
            mlflow.log_param("check", "mlflow")
            mlflow.log_metric("status", 1)

            if check_artifact_store:
                mlflow.log_artifact(__file__)

        # Cleanup - does not clean up the artifact store
        mlflow.delete_experiment(experiment.experiment_id)

    except Exception as e:
        print(f"MLflow check failed for {tracking_uri} with {e}.")

        sys.exit(1)

    print(f"MLflow check succeeded for {tracking_uri}.")

    sys.exit(0)


def main():
    parser = argparse.ArgumentParser(description="MLflow check.")
    parser.add_argument(
        "-t",
        "--tracking-uri",
        default="http://127.0.0.1:5000",
        dest="tracking_uri",
        help="The tracking URI of the MLflow server.",
    )
    parser.add_argument(
        "-na",
        "--no-check-artifact-store",
        action="store_false",
        dest="check_artifact_store",
        default=True,
        help="Do not check the artifact store during the check.",
    )

    args = parser.parse_args()

    check(args.tracking_uri, args.check_artifact_store)


if __name__ == "__main__":
    main()
