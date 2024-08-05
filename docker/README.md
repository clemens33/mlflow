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

Building image for [mlflow deployments server](https://mlflow.org/docs/latest/llms/deployments/index.html)
```bash
./build_image.sh \
--repository docker.io/clemens33/mlflow \
--genai \
--push
```

Build and push to repository

```bash
./build_image.sh \
--repository docker.io/clemens33/mlflow \
--tag latest \
--push
```

```bash
./build_image.sh \
--repository docker.io/clemens33/mlflow \
--genai \
--tag latest-deployments-server \
--push
``` 

## Run Container

```bash
docker run -d --name mlflow -p 5000:5000 localhost/mlflow:2.15.0-py3.11
```

```bash
docker run -d --name mlflow -p 5000:5000 docker.io/clemens33/mlflow:2.15.0-py3.11
```

Persist mlruns and mlartifacts on host machine (not using any backend)

```bash
if [ ! -d ./data ]; then mkdir ./data; fi && \
docker run -d --name mlflow -p 5000:5000 \
-v $(pwd)/data:/home/mlflow \
localhost/mlflow:2.15.0-py3.11
```

Run container for [mlflow deployments server](https://mlflow.org/docs/latest/llms/deployments/index.html). First create a .env-deployments-server.sh file with your API keys which are set as environment variables within the container.

```bash
echo '
# openai
OPENAI_API_KEY=xxx
OPENAI_API_KEY2=xxx

# anthropic
ANTHROPIC_API_KEY=xxx' > .env-deployments-server.sh
```

```bash
docker run --name mlflow-deployments-server \
-p 5000:5000 \
-v "$(pwd)/../samples/config.yaml:/home/mlflow/config.yaml" \
--env-file "$(pwd)/.env-deployments-server.sh" \
docker.io/clemens33/mlflow:2.15.0-deployments-server-py3.11 deployments-server
```
