# Helm Chart

Install and usage of [helm](https://helm.sh/). 

To generate templates from a chart with default values, run:

```bash
helm template mlflow
```

## Publish Chart

Navigate to root of repo and run:

```bash
helm package charts/mlflow
```

```bash
helm package charts/mlflow-deployments-server
```

```bash
helm repo index --url https://clemens33.github.io/mlflow .
```




