# Use the specified Python version
ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /tmp/requirements.txt

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# Set up mlflow user and home directory
RUN useradd -m -d /home/mlflow mlflow && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    chown mlflow:mlflow /usr/local/bin/entrypoint.sh

USER mlflow
WORKDIR /home/mlflow

VOLUME /home/mlflow

EXPOSE 5000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["server"]
