# Docker

## Build Image

Navigate to /docker and run - this will infer python and mlflow versions from using poetry.lock and pyproject.toml. Requires [poetry](https://python-poetry.org/).

```bash
./build_image.sh
```

Optional run help

```bash
./build_image.sh --help
```

```
Usage: ./build_image.sh [OPTIONS]

Options:
  -h, --help            Show this help message
  -t, --tag             Specify the registry, image name and tag - e.g. my.registry.io/ml/mlflow:2.7.1-py3.10
  -v, --version         Specify a version for the image - e.g. v1
  -p, --useproxy        Use specified http proxy for docker build
  -nc,--nocache         Do not use cache when building the image
```

Custom name/tag
```bash
./build_image.sh --tag localhost/mlflow
```

## Run Container

```bash
docker run -d --name mlflow -p 5000:5000 localhost/mlflow
```

Persist mlruns and mlartifacts on host machine (not using any backend)

```bash
if [ ! -d ./data ]; then mkdir ./data; fi && \
docker run -d --name mlflow -p 5000:5000 \
-v $(pwd)/data:/home/mlflow \
localhost/mlflow
```

## Run Container with Backend

```bash
docker network create ml-network
```

Using postgres backend, persisting data on host machine

```bash
if [ ! -d $(pwd)/data/pgdata ]; then mkdir $(pwd)/data/pgdata; fi && \
docker run -d --name ml-postgres --network ml-network -p 5432:5432 \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=postgres_password \
-e POSTGRES_DB=mlflow \
-v $(pwd)/data/pgdata:/var/lib/postgresql/data \
postgres:latest
```

```bash
docker run -d --name mlflow --network ml-network -p 5000:5000 \
-e MLFLOW_BACKEND_STORE_URI=postgresql+psycopg2://postgres:postgres_password@ml-postgres:5432/mlflow \
localhost/mlflow
```
