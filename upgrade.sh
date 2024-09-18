#!/bin/bash

# Upgrade MLflow to the latest version if it is not already up to date

poetry export -f requirements.txt --output requirements.txt --without-hashes --with=genai
REQUIREMENTS_FILE="requirements.txt"

PYTHON_VERSION=$(grep -m1 'python_version >=' $REQUIREMENTS_FILE | awk -F'"' '{print $2}')
MLFLOW_VERSION=$(grep -m1 'mlflow==' $REQUIREMENTS_FILE | awk -F'==' '{print $2}' | awk '{print $1}')

LATEST_MLFLOW_VERSION=$(curl -s https://pypi.org/pypi/mlflow/json | grep -o '"version":"[^"]*"' | sed 's/"version":"//;s/"//')

echo "Current MLflow version: $MLFLOW_VERSION"
echo "Latest MLflow version: $LATEST_MLFLOW_VERSION"

# compare versions
if [[ $MLFLOW_VERSION = $LATEST_MLFLOW_VERSION ]]; then
    echo "MLflow is already up to date"
    
    exit 0
fi

echo "Upgrading to latest versions $LATEST_MLFLOW_VERSION"

# upgrade dependencies
poetry add mlflow@latest psycopg2-binary@latest boto3@latest prometheus-flask-exporter@latest azure-storage-blob@latest azure-identity@latest gevent@latest
poetry add mlflow[genai]@latest --group genai

# upgrade version in pyproject.toml
PROJECT_VERSION=$(poetry version | awk '{print $2}')
NEW_PROJECT_VERSION=$(echo $LATEST_MLFLOW_VERSION-1)
poetry version $NEW_PROJECT_VERSION

# upgrade mlflow tag version in docker/README.md from MLFLOW_VERSION to LATEST_MLFLOW_VERSION
sed -i "s/$MLFLOW_VERSION/$LATEST_MLFLOW_VERSION/g" docker/README.md

# upgrade mlflow tag in charts
sed -i "s/$MLFLOW_VERSION/$LATEST_MLFLOW_VERSION/g" charts/mlflow/Chart.yaml
sed -i "s/$MLFLOW_VERSION/$LATEST_MLFLOW_VERSION/g" charts/mlflow-deployments-server/Chart.yaml




