# MLflow Container Setup

## Quick start

Requires [poetry](https://python-poetry.org/), [docker](https://docs.docker.com/engine/install/) and [docker compose](https://docs.docker.com/compose/).

```bash
poetry install
```

Build image (infer python and mlflow versions from poetry)

```bash
cd docker && \
./build_image.sh
```

Define environment variables (run in root folder of this repo)

```bash
echo '#!/bin/bash

# mlflow settings
export MLFLOW_PORT=5000
export POSTGRES_DATA=$(pwd)/data/pgdata

# db settings
export POSTGRES_USER=mlflow
export POSTGRES_PASSWORD=mlflow123

# mlflow s3 storage backend settings (e.g. can be minio)
export AWS_ACCESS_KEY_ID=youraccesskey
export AWS_SECRET_ACCESS_KEY=yoursecretaccesskey
export MLFLOW_S3_ENDPOINT_URL=https://minio.yourdomain.com
export MLFLOW_S3_BUCKET=s3://yourbucketname/yourfolder
export MLFLOW_S3_IGNORE_TLS=true' > env.sh
```

Start up mlflow + postgres backend

```bash
source env.sh && \
\
if [ ! -d "./data/pgdata" ] ; then mkdir -p $POSTGRES_DATA; fi && \
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

Run (client requires s3 credentials)

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

## [Helm](helm/README.md)

(upcoming)