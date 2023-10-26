#!/bin/bash

show_help() {
  echo "Usage: ./build_image.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help            Show this help message"
  echo "  -r, --repository      Specify the repository - e.g. my.repository.io/ml/mlflow - default set to localhost/mlflow"  
  echo "  -t, --tag             Specify the tag, if not defined is infered from poetry - e.g. 2.7.1-py3.10"  
  echo "  -p, --proxy           Use specified http proxy for docker build - e.g. http://localhost:3128, default not set"
  echo "  -pu,--push            Push the image to the repository after building it, default not set"
  echo "  -nc,--nocache         Do not use cache when building the image"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help) show_help; exit 0;;    
    -r|--repository) REPOSITORY="$2"; shift; shift ;;    
    -t|--tag) TAG="$2"; shift; shift ;;    
    -p|--proxy) USEPROXY=1; HTTP_PROXY="$2"; shift; shift ;;
    -pu|--push) PUSH=1; shift ;;
    -nc|--nocache) NO_CACHE="--no-cache"; shift ;;    
    *) echo "Unknown parameter: $1"; show_help; exit 1 ;;    
  esac
done

# Export requirements from poetry and infer python and mlflow versions
poetry export -f requirements.txt --output requirements.txt --without-hashes
REQUIREMENTS_FILE="requirements.txt"
PYTHON_VERSION=$(grep -m1 'python_version >=' $REQUIREMENTS_FILE | awk -F'"' '{print $2}')
MLFLOW_VERSION=$(grep -m1 'mlflow==' $REQUIREMENTS_FILE | awk -F'==' '{print $2}' | awk '{print $1}')

# Set default values if not provided
NO_CACHE=${NO_CACHE:-""}
REPOSITORY=${REPOSITORY:-"localhost/mlflow"}
TAG=${TAG:-"${MLFLOW_VERSION}-py${PYTHON_VERSION}"}

# Set fully qualified image name/tag
TAG="${REPOSITORY}:${TAG}"

# Conditional setting of proxy build arguments
if [[ "$USEPROXY" -eq 1 ]]; then
    PROXY_ARGS="--build-arg HTTP_PROXY=${HTTP_PROXY}"
else
    PROXY_ARGS=""
fi

# Print build arguments
echo "Build arguments:"
echo "  PYTHON_VERSION: ${PYTHON_VERSION}"
echo "  TAG: ${TAG}"
echo "  PROXY_ARGS: ${PROXY_ARGS}"
echo "  NO_CACHE: ${NO_CACHE}"


# Build the Docker image
docker build \
  ${NO_CACHE} \
  --build-arg PYTHON_VERSION=${PYTHON_VERSION} \
  ${PROXY_ARGS} \
  -t ${TAG} \
  -f Dockerfile .

# if build fails, exit
if [[ $? -ne 0 ]]; then
    echo "Build failed"
    exit 1
fi

# Print image size and tag
echo "Image size:"
docker images ${TAG} --format "{{.Size}}"
echo "Image name:tag"
echo ${TAG}

# Push image to repository if specified
if [[ "$PUSH" -eq 1 ]]; then
    echo ""
    echo "Pushing image to repository..."

    # first login to registry - first get the registry url from the image name
    REGISTRY=$(echo ${TAG} | cut -d'/' -f1)

    echo "Logging in to registry: ${REGISTRY}"

    # then login to the registry
    docker login ${REGISTRY}

    docker push ${TAG}
    echo "Image pushed to repository"
fi
