## Simple setup for mlflow + mysql backend store using docker compose 
**(artifact store points to external s3 bucket+host+credentials - for simple (one command) self hosted s3 (minio) storage refer to other repo (e.g. https://github.com/clemens33/minio)**

- Requires [docker compose](https://docs.docker.com/compose/)
- Clone/fork this repo, open terminal and cd into it
- Copy/adapt the following command and run it 
  - it creates a local env.sh (not versioned - gitignored) file with all relevant settings (adapt as needed).
  - for artifact storage the mlflow s3 artifact part of the settings must be set accordingly - if not mlflow within the container starts and runs but has no access to any s3 artifacts

```
echo '#!/bin/bash

# mlflow settings
export MLFLOW_PORT=5000
export MLFLOW_DB_LOCATION=~/data/mlflow/db/

# db settings
export MYSQL_DATABASE=mlflow
export MYSQL_USER=mlflow
export MYSQL_PASSWORD=mlflow123
export MYSQL_ROOT_PASSWORD=root123

# adminer settings (for db maintenance purposes)
export ADMINER_PORT=8080

# mlflow s3 storage backend settings (e.g. can be minio)
export AWS_ACCESS_KEY_ID=youraccesskey
export AWS_SECRET_ACCESS_KEY=yoursecretaccesskey
export MLFLOW_S3_ENDPOINT_URL=https://minio.yourdomain.com
export MLFLOW_S3_BUCKET=s3://yourbucketname/yourfolder
export MLFLOW_S3_IGNORE_TLS=true' > env.sh
```

- To start mlflow + mysql backend storage run - mlflow backend db will be persisted in MLFLOW_DB_LOCATION (e.g. see above in "~/data/mlflow/db" - make sure the location exists) 
```
source env.sh && \
\
if [ ! -d "./db" ] ; then ln -s $MLFLOW_DB_LOCATION ./db; fi && \
\
docker-compose pull && \
docker-compose build --pull && \
docker-compose up --build --remove-orphans
```

- After startup mlflow tracking server is running on "http://localhost:5000" (depending on your MLFLOW_PORT).

- (optional) [start](./start.sh)/[stop](./stop.sh) mlflow setup with the provided scripts - env.sh with relevant settings must be available

### Test mlflow setup [TESTME](./TESTME.ipynb)

- Create a test conda environment (requires [conda](https://docs.anaconda.com/anaconda/install/)
- To test the following steps setup the following conda environment
```
conda env create -f environment.yml
```
```
conda activate mlflow
```

- Start the jupyter notebook to test mlflow setup
```
jupyter notebook TESTME.ipynb
```