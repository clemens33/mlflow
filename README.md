# MLflow Container Setup

Setup focuses on experiment and artifact tracking using [mlflow](https://mlflow.org/docs/latest/tracking.html). 

## Quick start

Requires [poetry](https://python-poetry.org/), [docker](https://docs.docker.com/engine/install/) and [docker compose](https://docs.docker.com/compose/).

```bash
poetry install
```

Build image, set environment variables, and start containers (within docker folder)

```bash
cd docker && \
./build_image.sh \
--repository localhost/mlflow \
--tag latest && \
\
echo '#!/bin/bash

# mlflow settings
export MLFLOW_PORT=5000

export POSTGRES_DATA=$(pwd)/data/pgdata
export STORAGE_DATA=$(pwd)/data/storage

# db settings
export POSTGRES_USER=mlflow
export POSTGRES_PASSWORD=mlflow123

# (optional) mlflow s3 storage backend settings (e.g. can be minio)
# export MLFLOW_ARTIFACTS_DESTINATION=s3://yourbucketname/yourfolder
# export AWS_ACCESS_KEY_ID=youraccesskey
# export AWS_SECRET_ACCESS_KEY=yoursecretaccesskey
# export MLFLOW_S3_ENDPOINT_URL=https://minio.yourdomain.com
# export MLFLOW_S3_IGNORE_TLS=true' > .env.sh && \
\
source .env.sh && \
\
if [ ! -d "./data/pgdata" ] ; then mkdir -p $POSTGRES_DATA; fi && \
if [ ! -d "./data/storage" ] ; then mkdir -p $STORAGE_DATA; fi && \
\
docker compose up -d
```

Now checkout [http://localhost:5000](http://localhost:5000).

## Samples

Run sample tracking script

```bash
poetry run python samples/tracking.py
```

Run sample artifact script

```bash
poetry run python samples/artifacts.py
```

Navigate to [http://localhost:5000](http://localhost:5000) to see the MLflow UI and the experiment tracking.

## Local Setup

Using plain python and mlflow server.

### Basic

Using [poetry](https://python-poetry.org/). Runs and artifacts are stored in the `mlruns` and `mlartifacts` directories.

```bash
poetry install && \
poetry run mlflow server --host 0.0.0.0
```

### Backends

#### Database

Using [postgres](https://www.postgresql.org/) as backend.

```bash
docker run -d --name ml-postgres -p 5432:5432 \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=postgres_password \
-e POSTGRES_DB=mlflow \
postgres:latest
```

Runs mlflow server with postgres backend (only psycopg2 supported)

```bash
poetry run mlflow server --backend-store-uri postgresql+psycopg2://postgres:postgres_password@localhost:5432/mlflow --host 0.0.0.0
```

Run sample tracking script

```bash
poetry run python samples/tracking.py
```

#### Artifacts Store

##### s3

Set S3 credentials and endpoint URL

```bash
echo '
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export MLFLOW_S3_ENDPOINT_URL=...
' > .env.sh
```

Start mlflow server with s3 backend (default)

```bash
source .env.sh && \
poetry run mlflow server \
--backend-store-uri postgresql+psycopg2://postgres:postgres_password@localhost:5432/mlflow \
--default-artifact-root s3://my-bucket/mlflow/test \
--host 0.0.0.0
```

Run (client reqpuires s3 credentials)

```bash
source .env.sh && \
poetry run python samples/artifacts.py
```

Proxied s3 backend for artifacts (client do not need to know s3 credentials)

```bash
source .env.sh && \
poetry run mlflow server \
--backend-store-uri postgresql+psycopg2://postgres:postgres_password@localhost:5432/mlflow \
--artifacts-destination s3://my-bucket/mlflow/test \
--host 0.0.0.0
```

Run (client do not need to know s3 credentials)

```bash
poetry run python samples/artifacts.py
```

##### azure blob storage

Set azure credentials and endpoint URL - more info [here](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-keys-manage?tabs=azure-portal#view-account-access-keys) and [here](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-python?tabs=connection-string%2Croles-azure-portal%2Csign-in-azure-cli#authenticate-to-azure-and-authorize-access-to-blob-data).

```bash
echo "
export AZURE_STORAGE_CONNECTION_STRING='AccountName=<YOUR_ACCOUNT_NAME>;AccountKey=<YOUR_KEY>;EndpointSuffix=core.windows.net;DefaultEndpointsProtocol=https;'
export AZURE_STORAGE_ACCESS_KEY='<YOUR_KEY>'
" > .env_azure.sh
```

Proxied azure blob storage backend for artifacts (client do not need to know azure credentials)

```bash
source .env_azure.sh && \
poetry run mlflow server \
--backend-store-uri postgresql+psycopg2://postgres:postgres_password@localhost:5432/mlflow \
--artifacts-destination wasbs://my-container@my-storage-account.blob.core.windows.net/my-folder \
--host 0.0.0.0
```

Run (client do not need to know azure credentials)

```bash
poetry run python samples/artifacts.py
```

#### Metrics

Using [prometheus](https://prometheus.io/) as metrics backend.

```bash
source .env.sh && \
poetry run mlflow server \
--backend-store-uri postgresql+psycopg2://postgres:postgres_password@localhost:5432/mlflow \
--artifacts-destination s3://my-bucket/mlflow/test \
--expose-prometheus ./metrics \
--host 0.0.0.0
```

## [Docker](docker/README.md)

## [Helm](charts/README.md)

For running mlflow as tracking service it is highly recommended to use gunicorn with gevent workers (non blocking io optimized). The following describes a corresponding config map

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mlflow-additional-config
data:
  MLFLOW_HOST: "0.0.0.0"
  MLFLOW_PORT: "5000"
  MLFLOW_ADDITIONAL_OPTIONS: "--gunicorn-opts '--worker-class gevent --threads 4 --timeout 300 --keep-alive 300 --log-level INFO'"
```