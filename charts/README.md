# Helm Chart

Install and usage of [helm](https://helm.sh/). 

To generate templates from a chart with default values, run:

```bash
helm template mlflow
```

## Publish Chart

Navigate to /charts and run:

```bash
helm package mlflow
```

```bash
helm repo index --url https://clemens33.github.io/mlflow/charts .
```




