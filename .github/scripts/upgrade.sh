#!/bin/bash

show_help() {
  echo "Usage: ./upgrade.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help            Show this help message"
  echo "  -s, --suffix          Specify the version suffix - e.g. 2.7.1-1, default set to 1"  
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help) show_help; exit 0;;    
    -s|--suffix) VERSION_SUFFIX="$2"; shift; shift ;;
    *) echo "Unknown parameter: $1"; show_help; exit 1 ;;
  esac
done

# set defaults
VERSION_SUFFIX=${VERSION_SUFFIX:-"1"}

is_github_actions() {
    [ -n "$GITHUB_ACTIONS" ]
}

if is_github_actions; then
    echo "Running in GitHub Actions"
    
    cd "$GITHUB_WORKSPACE" || exit 1
fi

echo "Current directory: $(pwd)"

poetry export -f requirements.txt --output requirements.txt --without-hashes --with=genai || exit 1
REQUIREMENTS_FILE="requirements.txt"

PYTHON_VERSION=$(grep -m1 'python_version >=' $REQUIREMENTS_FILE | awk -F'"' '{print $2}')
MLFLOW_VERSION=$(grep -m1 'mlflow==' $REQUIREMENTS_FILE | awk -F'==' '{print $2}' | awk '{print $1}')

LATEST_MLFLOW_VERSION=$(curl -s https://pypi.org/pypi/mlflow/json | grep -o '"version":"[^"]*"' | sed 's/"version":"//;s/"//')

echo "Current MLflow version: $MLFLOW_VERSION"
echo "Latest MLflow version: $LATEST_MLFLOW_VERSION"

# compare versions
if [[ $MLFLOW_VERSION = $LATEST_MLFLOW_VERSION ]]; then
    echo "MLflow is already up to date"

    if is_github_actions; then
      echo "mlflow_updated=false" >> $GITHUB_OUTPUT
    fi
    
    exit 0
fi

echo "Upgrading to latest versions $LATEST_MLFLOW_VERSION"

# upgrade dependencies
poetry add mlflow@latest psycopg2-binary@latest boto3@latest prometheus-flask-exporter@latest azure-storage-blob@latest azure-identity@latest gevent@latest || exit 1
poetry add mlflow[genai]@latest --group genai || exit 1

# upgrade version in pyproject.toml
PROJECT_VERSION=$(poetry version | awk '{print $2}')
NEW_PROJECT_VERSION=$(echo $LATEST_MLFLOW_VERSION-$VERSION_SUFFIX)
poetry version $NEW_PROJECT_VERSION

# upgrade mlflow tag version in docker/README.md from MLFLOW_VERSION to LATEST_MLFLOW_VERSION
sed -i "s/$MLFLOW_VERSION/$LATEST_MLFLOW_VERSION/g" docker/README.md

# upgrade mlflow tag in charts
sed -i "s/$MLFLOW_VERSION/$LATEST_MLFLOW_VERSION/g" charts/mlflow/Chart.yaml
sed -i "s/$MLFLOW_VERSION/$LATEST_MLFLOW_VERSION/g" charts/mlflow-deployments-server/Chart.yaml

if is_github_actions; then
    echo "latest_mlflow_version=${LATEST_MLFLOW_VERSION}" >> $GITHUB_OUTPUT    
    echo "mlflow_updated=true" >> $GITHUB_OUTPUT
fi

exit 0

