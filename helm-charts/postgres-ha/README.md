# Helm chart: postgres-ha

Renders a Zalando `postgresql` custom resource (Spilo + Patroni). Deployed by **Argo CD** (preferred) or Helm CLI.

## Prerequisites

1. Zalando Postgres Operator installed (see Argo CD app `postgres-operator`).
2. CRD present: `kubectl get crd postgresqls.acid.zalan.do`
3. A StorageClass — set `volume.storageClass` in `values-local.yaml` or `values-eks.yaml`.

## Helm CLI (bootstrap / debug only)

```bash
helm upgrade --install postgres-ha ./helm-charts/postgres-ha \
  -n postgres-ha --create-namespace \
  -f ./helm-charts/postgres-ha/values-local.yaml
```

Prefer GitOps: [`../../envs/local/postgres-ha/application.yaml`](../../envs/local/postgres-ha/application.yaml).
