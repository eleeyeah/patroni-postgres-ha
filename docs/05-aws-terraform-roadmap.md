# Phase 5 — AWS / EKS roadmap (lesson 200)

**Do not start here.** Prove Phase 2 on local kubeadm with Argo CD first.

## Reuse lesson 200 — do not rebuild EKS from scratch

This repo already contains a working EKS + Argo CD Terraform stack:

| Piece | Path |
|-------|------|
| EKS / VPC / nodes | [`tutorials/lessons/200/terraform`](../../tutorials/lessons/200/terraform) (`7-eks.tf`, `8-nodes.tf`, …) |
| Argo CD Helm release | [`11-argocd.tf`](../../tutorials/lessons/200/terraform/11-argocd.tf) |
| Argo CD values | [`values/argocd.yaml`](../../tutorials/lessons/200/terraform/values/argocd.yaml) |
| App-of-Apps pattern | [`tutorials/lessons/200/argocd`](../../tutorials/lessons/200/argocd) |

**Patroni Postgres HA on EKS** = same Helm charts + `envs/eks` Argo CD Applications, pointed at the EKS cluster’s Argo CD (after lesson 200 is applied).

## Overlay differences

| Concern | Local kubeadm | EKS (lesson 200) |
|---------|---------------|------------------|
| Argo CD install | Helm on kubeadm | Terraform `helm_release.argocd` |
| StorageClass | whatever you run (local-path, …) | EBS CSI → set `gp3` in `values-eks.yaml` |
| GitOps apps | `envs/local/*` | `envs/eks/*` (enable in ApplicationSet) |
| Client entry | port-forward / MetalLB | NLB / in-cluster Service |
| IAM / backups | N/A early | IRSA later for S3 WAL |

## Steps (future)

1. Apply / use lesson 200 Terraform until Argo CD is reachable on EKS.
2. Ensure EBS CSI and a `gp3` StorageClass (addon module or AWS console/CLI).
3. Set `repoURL` ([argocd/REPO.md](../argocd/REPO.md)); register git repo in that Argo CD.
4. Uncomment `- env: eks` in [`argocd/project/applicationset.yaml`](../argocd/project/applicationset.yaml) **or** apply `envs/eks/*/application.yaml` on the EKS context.
5. Sync operator (wave 0) then postgres-ha (wave 1).
6. Optional: add thin wrappers under `terraform/modules/` only for gaps (EBS CSI, IRSA) not covered by lesson 200.

## Checklist

- [ ] Local Phase 2 proven
- [ ] Lesson 200 EKS + Argo CD up
- [ ] `values-eks.yaml` StorageClass correct
- [ ] `envs/eks` apps Synced/Healthy
- [ ] Cost notes from [04-cost-optimization.md](04-cost-optimization.md) applied

See also [`../terraform/README.md`](../terraform/README.md).
