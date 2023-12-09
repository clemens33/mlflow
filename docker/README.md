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

Custom registry and image name (tag is inferred).
```bash
./build_image.sh \
--repository docker.io/clemens33/mlflow \
--push
```

Build and push to repository

```bash
./build_image.sh \
--repository docker.io/clemens33/mlflow \
--tag latest \
--push
```

## Run Container

```bash
docker run -d --name mlflow -p 5000:5000 localhost/mlflow:2.9.1-py3.10
```

Persist mlruns and mlartifacts on host machine (not using any backend)

```bash
if [ ! -d ./data ]; then mkdir ./data; fi && \
docker run -d --name mlflow -p 5000:5000 \
-v $(pwd)/data:/home/mlflow \
localhost/mlflow:2.9.1-py3.10
```