name: upgrade-mlflow-build-images-and-charts

on:
  workflow_dispatch:

jobs:
  upgrade:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository      
      uses: actions/checkout@v3
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        fetch-depth: 1

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install Poetry
      uses: abatilo/actions-poetry@v2
      with:
        poetry-version: 'latest'

    - name: Configure Git      
      run: |
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"

    - name: Run upgrade script
      id: upgrade
      run: |
        chmod +x .github/scripts/upgrade.sh
        .github/scripts/upgrade.sh

    - name: Commit and push changes
      id: commit
      if: ${{ steps.upgrade.outputs.mlflow_updated == 'true' }}
      run: |
        git add --all
        git commit -m "Upgraded mlflow to ${{ steps.upgrade.outputs.latest_mlflow_version }}"
        git push origin ${GITHUB_REF#refs/heads/}

    - name: Set up Docker Buildx
      if: ${{ steps.upgrade.outputs.mlflow_updated == 'true' }}
      uses: docker/setup-buildx-action@v1

    - name: Login to DockerHub
      if: ${{ steps.upgrade.outputs.mlflow_updated == 'true' }}
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}

    - name: Build and push Docker images
      id: build_images
      if: ${{ steps.upgrade.outputs.mlflow_updated == 'true' }}
      run: |
        chmod +x docker/build_image.sh
        cd docker
        ./build_image.sh --repository docker.io/clemens33/mlflow --push
        ./build_image.sh --repository docker.io/clemens33/mlflow --genai --push
        ./build_image.sh --repository docker.io/clemens33/mlflow --push --tag latest
        ./build_image.sh --repository docker.io/clemens33/mlflow --genai --push --tag latest-deployments-server
        
    - name: Set up Helm
      if: ${{ steps.upgrade.outputs.mlflow_updated == 'true' }}
      uses: azure/setup-helm@v4.2.0
      with:
        version: 'latest'

    - name: Package Helm charts
      id: package_charts
      if: ${{ steps.upgrade.outputs.mlflow_updated == 'true' }}
      run: |
        git fetch origin charts
        git checkout -b charts origin/charts
        git merge ${GITHUB_REF#refs/heads/}
        helm package charts/mlflow
        helm package charts/mlflow-deployments-server
        helm repo index --url https://clemens33.github.io/mlflow .
        git add --all
        git commit -m "Upgraded mlflow charts to ${{ steps.upgrade.outputs.latest_mlflow_version }}"
        git push origin charts