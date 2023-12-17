#!/bin/bash
set -e

MLFLOW_HOME_DIR="/home/mlflow"
cd $MLFLOW_HOME_DIR

if [[ "$1" = "server" ]]; then
    shift 1        

    # e.g. (postgresql+psycopg2://postgres:postgres_password@localhost:5432/mlflow)
    BACKEND_STORE_URI=${MLFLOW_BACKEND_STORE_URI:-$MLFLOW_HOME_DIR/mlruns}

    if [[ -n $MLFLOW_ARTIFACTS_DESTINATION ]]; then
        if [[ -n $AWS_ACCESS_KEY_ID && -n $AWS_SECRET_ACCESS_KEY && -n $MLFLOW_S3_ENDPOINT_URL ]]; then
            
            # e.g. (s3://my-bucket/mlflow/test)
            ARTIFACTS_DESTINATION="$MLFLOW_ARTIFACTS_DESTINATION"
        elif [[ -n $AZURE_STORAGE_CONNECTION_STRING && -n $AZURE_STORAGE_ACCESS_KEY ]]; then
            
            # e.g. (wasbs://my-container@my-storage-account.blob.core.windows.net/my-folder)
            ARTIFACTS_DESTINATION="$MLFLOW_ARTIFACTS_DESTINATION"
        else
            echo "Missing AWS credentials, S3 configuration or Azure Storage configuration, using local artifacts destination."
                        
            ARTIFACTS_DESTINATION="$MLFLOW_HOME_DIR/mlartifacts"
        fi
    else
        ARTIFACTS_DESTINATION="$MLFLOW_HOME_DIR/mlartifacts"
    fi

    if [[ -n $MLFLOW_EXPOSE_PROMETHEUS ]]; then
        PROMETHEUS_ARG="--expose-prometheus $MLFLOW_HOME_DIR/metrics"
    else
        PROMETHEUS_ARG=""
    fi

    # to disable db upgrade, set env var MLFLOW_NO_DB_UPGRADE=1
    if [[ -z $MLFLOW_NO_DB_UPGRADE ]]; then
        echo "Running MLFlow database upgrade..."
        
        mlflow db upgrade $BACKEND_STORE_URI
    else
        echo "Skipping MLFlow database upgrade..."
    fi

    echo "Starting MLFlow server..."
    mlflow server \
    --backend-store-uri $BACKEND_STORE_URI \
    --artifacts-destination $ARTIFACTS_DESTINATION \
    $PROMETHEUS_ARG \
    --workers ${MLFLOW_WORKERS:-4} \
    --host 0.0.0.0 \
    --port 5000
else
    eval "$@"
fi

# prevent docker exit
tail -f /dev/null
