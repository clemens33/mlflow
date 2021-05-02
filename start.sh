#!/bin/bash

source env.sh

if [ ! -d "./db" ] ; then ln -s $MLFLOW_DB_LOCATION ./db; fi

docker-compose pull
docker-compose build --pull
docker-compose up --build --remove-orphans -d