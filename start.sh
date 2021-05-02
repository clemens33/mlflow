#!/bin/bash

source env.sh

ln -s $MLFLOW_DB_LOCATION ./mlflow-db

docker-compose pull
docker-compose build --pull
docker-compose up --build --remove-orphans -d