# Phase 3 — Monitoring

Goal: observe primary role, replication lag, disk pressure, and operator health without SSHing into nodes.

## Prerequisites

- Phase 2 cluster running in `postgres-ha`
- A metrics stack (Prometheus Operator / kube-prometheus-stack, or equivalent) — **not** installed by this scaffold

## What to scrape

| Source | Why |
|--------|-----|
| Postgres / Spilo exporter endpoints | Connections, lag, database stats |
| Pod / PVC metrics (kubelet / kube-state-metrics) | Restarts, PVC nearly full |
| Postgres operator Deployment | Operator down → no reconciliation |

Exact ports/paths depend on Spilo/operator version. Confirm with:

```bash
kubectl -n postgres-ha get pods -o wide
kubectl -n postgres-ha describe pod <pod> | grep -i -E 'port|prometheus|export'
```

## Placeholders in this repo

See [`../monitoring/`](../monitoring/README.md) for a commented ServiceMonitor stub and alert ideas. Enable them only after Prometheus CRDs exist.

## Alert ideas (minimum set)

1. **No primary** — master Service has zero ready endpoints for > N seconds  
2. **Replica lag** — lag above threshold  
3. **PVC nearly full** — e.g. > 85%  
4. **Operator down** — postgres-operator replicas unavailable  
5. **Pod CrashLoopBackOff** on Spilo pods  

## Dashboards

Import community Postgres / Patroni dashboards into Grafana, or build a thin board with:

- Role per instance (primary vs replica)
- Connections
- Replication lag
- PVC used bytes
- Failover count / timeline (from logs or Patroni metrics if available)

## Checklist

- [ ] Metrics endpoints identified
- [ ] Scrape config / ServiceMonitor applied
- [ ] Dashboard reachable
- [ ] Alerts wired to a notification channel (optional for lab)

Return to [PHASES.md](../PHASES.md#phase-3--monitoring).
