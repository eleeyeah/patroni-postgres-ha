# Alert ideas (Phase 3)

Translate into PrometheusRule / Alertmanager once metrics exist.

| Alert | Intent | Hint |
|-------|--------|------|
| PostgresPrimaryMissing | No ready endpoints on master Service | `kube_endpoint_address_available` or probe master Service |
| PostgresReplicaLagHigh | Replica falling behind | Exporter lag metric / Patroni lag |
| PostgresPVCNearlyFull | Disk pressure | `kubelet_volume_stats_used_bytes / capacity > 0.85` |
| PostgresOperatorDown | No reconciliation | Deployment `postgres-operator` unavailable replicas |
| SpiloCrashLooping | Unstable pods | `kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff"}` |

Lab: start with recording + Grafana; add paging alerts only when you care about night pages.
