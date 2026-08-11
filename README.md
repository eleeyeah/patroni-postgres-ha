# Patroni Postgres HA

High-availability PostgreSQL on Kubernetes using the **Zalando Postgres Operator** (Spilo + **Patroni**).

**Deploy path:** **Helm charts** + **Argo CD** (GitOps), same style as [`tutorials/lessons/200`](../tutorials/lessons/200/README.md).

**Local first** on kubeadm ([`../cluster/`](../cluster/README.md)). **EKS** reuses the Terraform + Argo CD install from lesson 200, then syncs the `envs/eks` apps.

## Phase index

| Phase | Focus | Start here |
|-------|--------|------------|
| 1 | Scaffolding & docs | [PHASES.md](PHASES.md#phase-1--scaffolding) |
| 2 | Local deploy (Helm + Argo CD) | [PHASES.md](PHASES.md#phase-2--local-deploy) · [argocd/](argocd/README.md) |
| 3 | Monitoring | [PHASES.md](PHASES.md#phase-3--monitoring) · [docs/03-monitoring.md](docs/03-monitoring.md) |
| 4 | Cost optimization | [PHASES.md](PHASES.md#phase-4--cost-optimization) · [docs/04-cost-optimization.md](docs/04-cost-optimization.md) |
| 5 | AWS / EKS (lesson 200 + overlays) | [PHASES.md](PHASES.md#phase-5--aws-terraform) · [terraform/](terraform/README.md) |

Master checklist: **[PHASES.md](PHASES.md)**

## Docs

| Doc | Purpose |
|-----|---------|
| [01-concepts-from-technotim.md](docs/01-concepts-from-technotim.md) | Proxmox → K8s map |
| [02-local-kubernetes.md](docs/02-local-kubernetes.md) | Local Helm + Argo CD runbook |
| [03-monitoring.md](docs/03-monitoring.md) | Metrics / alerts |
| [04-cost-optimization.md](docs/04-cost-optimization.md) | Sizing + AWS cost preview |
| [05-aws-terraform-roadmap.md](docs/05-aws-terraform-roadmap.md) | EKS via lessons/200 |

## Layout

```text
patroni-postgres-ha/
  helm-charts/postgres-ha/   # Helm chart → postgresql CR
  argocd/                    # App-of-Apps + AppProject + ApplicationSet
  envs/local/                # Argo CD Applications (operator + cluster)
  envs/eks/                  # Same for EKS (after lesson 200)
  monitoring/  cost/  terraform/  scripts/
```

No Kustomize — Helm only.

## Prerequisites (local)

1. Healthy kubeadm cluster — [`../cluster/`](../cluster/README.md)
2. StorageClass available; set it in [`helm-charts/postgres-ha/values-local.yaml`](helm-charts/postgres-ha/values-local.yaml)
3. Argo CD installed on the cluster
4. This project pushed to a git remote; set `repoURL` per [`argocd/REPO.md`](argocd/REPO.md)

```bash
./scripts/check-prereqs.sh
```

## Quick path (local)

1. Fix `repoURL` placeholders ([argocd/REPO.md](argocd/REPO.md))
2. Set `volume.storageClass` in `values-local.yaml`
3. `kubectl apply -f argocd/project/project.yaml`
4. `kubectl apply -f argocd/project/applicationset.yaml`  
   (or `kubectl apply -f argocd/root-app.yaml`)
5. Watch Argo CD: operator (wave 0) then `postgres-ha` (wave 1)

## Secrets

Never commit passwords. Operator generates DB credentials into Secrets.

## Related

- EKS + Argo CD Terraform: [`tutorials/lessons/200/terraform`](../tutorials/lessons/200/terraform) (`11-argocd.tf`)
- Lesson 200 GitOps apps pattern: [`tutorials/lessons/200/argocd`](../tutorials/lessons/200/argocd)
