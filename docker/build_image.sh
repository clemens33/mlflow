#!/bin/bash

# optional http proxy required for docker build
HTTP_PROXY="http://localhost:3128"

REGISTRY="localhost"
IMAGE_NAME="${REGISTRY}/mlflow"

show_help() {
  echo "Usage: ./build_image.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help            Show this help message"
  echo "  -t, --tag             Specify the registry, image name and tag - e.g. my.registry.io/mlflow:2.7.1-py3.10"
  echo "  -v, --version         Specify a version for the image - e.g. v1"
  echo "  -p, --useproxy        Use specified http proxy for docker build"
  echo "  -nc,--nocache         Do not use cache when building the image"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help) show_help; exit 0;;
    -t|--tag) TAG="$2"; shift; shift ;;
    -v|--version) VERSION="$2"; shift; shift ;;
    -p|--useproxy) USEPROXY=1; shift ;;
    -nc|--nocache) NO_CACHE="--no-cache"; shift ;;    
    *) echo "Unknown parameter: $1"; show_help; exit 1 ;;    
  esac
done

# Export requirements from poetry and infer python and mlflow versions
poetry export -f requirements.txt --output requirements.txt --without-hashes
REQUIREMENTS_FILE="requirements.txt"
PYTHON_VERSION=$(grep -m1 'python_version >=' $REQUIREMENTS_FILE | awk -F'"' '{print $2}')
MLFLOW_VERSION=$(grep -m1 'mlflow==' $REQUIREMENTS_FILE | awk -F'==' '{print $2}' | awk '{print $1}')

# Set defaults if not provided
VERSION=${VERSION:-"v1"}
NO_CACHE=${NO_CACHE:-""}

# Conditionally setting the image+tag if not provided
if [[ -z ${TAG+x} ]]; then
    TAG="${IMAGE_NAME}:${MLFLOW_VERSION}-${VERSION}-py${PYTHON_VERSION}"
fi

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

# Ask user if image should be pushed to registry (default: no)
read -p "Push image to registry? [y/N] " -n 1 -r

# Push image to registry if user answered yes, then ask for registry credentials
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Pushing image to registry..."

    # first login to registry - first get the registry url from the image name
    REGISTRY=$(echo ${TAG} | cut -d'/' -f1)

    # then login to the registry
    docker login ${REGISTRY}

    docker push ${TAG}
    echo "Image pushed to registry"
fi
