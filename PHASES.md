# Phases checklist — Patroni Postgres HA

Work **in order**. Deploy with **Helm + Argo CD** (no Kustomize). Do not start Phase 5 until local (Phase 2) is proven.

---

## Phase 1 — Scaffolding

- [x] Project tree (`helm-charts/`, `argocd/`, `envs/`, `docs/`, `monitoring/`, `cost/`, `terraform/`, `scripts/`)
- [x] Concept map (Proxmox → K8s)
- [x] Local prerequisites documented
- [x] Secrets / `.gitignore`
- [x] Link from parent [`../README.md`](../README.md)
- [x] Helm chart + Argo CD apps (no Kustomize)

**Done when:** Phase 2 can be followed without the Proxmox tutorial as the runbook.

---

## Phase 2 — Local deploy (Helm + Argo CD)

Target: kubeadm cluster from [`../cluster/`](../cluster/README.md).

1. [ ] Confirm cluster healthy — `kubectl get nodes -o wide`
2. [ ] Choose/create **StorageClass**; set `volume.storageClass` in [`helm-charts/postgres-ha/values-local.yaml`](helm-charts/postgres-ha/values-local.yaml)
3. [ ] Install **Argo CD** on the local cluster (Helm chart `argo/argo-cd`, or reuse lesson 200 values as a guide)
4. [ ] Push this project to git; set every `repoURL` per [`argocd/REPO.md`](argocd/REPO.md); register the repo in Argo CD if private
5. [ ] Apply AppProject + ApplicationSet (or root app) — [`argocd/README.md`](argocd/README.md)
6. [ ] Sync **postgres-operator** (wave 0) — upstream Zalando Helm chart
7. [ ] Sync **postgres-ha** (wave 1) — local Helm chart → `postgresql` CR (3 instances)
8. [ ] Verify pods/Services/PVCs; connect via port-forward or in-cluster DNS
9. [ ] Failover smoke test

**Done when:** writes work through the master Service and survive primary pod loss.

Details: [docs/02-local-kubernetes.md](docs/02-local-kubernetes.md)

---

## Phase 3 — Monitoring

- [ ] Metrics endpoints for Spilo/operator
- [ ] ServiceMonitor / scrape config ([`monitoring/`](monitoring/README.md))
- [ ] Dashboards + alerts (primary missing, lag, PVC, operator down)
- [ ] Prometheus stack available separately

Details: [docs/03-monitoring.md](docs/03-monitoring.md)

---

## Phase 4 — Cost optimization

- [ ] Right-size CPU/memory/disk ([`cost/`](cost/README.md))
- [ ] Instance count vs hardware
- [ ] AWS preview: EBS, multi-AZ, no Spot for primary
- [ ] Retention / idle teardown checklist

Details: [docs/04-cost-optimization.md](docs/04-cost-optimization.md)

---

## Phase 5 — AWS / EKS (lesson 200)

Use existing EKS + Argo CD from [`../tutorials/lessons/200/terraform`](../tutorials/lessons/200/terraform) — do not reinvent the cluster.

- [ ] Read [`terraform/README.md`](terraform/README.md) and [docs/05-aws-terraform-roadmap.md](docs/05-aws-terraform-roadmap.md)
- [ ] Ensure EBS CSI + `gp3` (or set `values-eks.yaml` accordingly)
- [ ] Enable `env: eks` in ApplicationSet (or apply `envs/eks/*` apps on the EKS Argo CD)
- [ ] Set `repoURL`; sync operator then postgres-ha
- [ ] Optional later: thin Terraform modules under `terraform/modules/` only for addons/values not already in lesson 200

**Done when:** same Helm chart is healthy on EKS via Argo CD.

---

## Phase dependency graph

```text
Phase 1 (scaffold)
    └── Phase 2 (local Helm + Argo CD)
            ├── Phase 3 (monitoring)
            ├── Phase 4 (cost)
            └── Phase 5 (EKS via lessons/200 + envs/eks)
```
