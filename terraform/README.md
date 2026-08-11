# Terraform (Phase 5)

**Primary EKS + Argo CD stack lives in lesson 200**, not here:

- [`../../tutorials/lessons/200/terraform`](../../tutorials/lessons/200/terraform) — VPC, EKS, nodes, Argo CD (`11-argocd.tf`)
- GitOps pattern: [`../../tutorials/lessons/200/argocd`](../../tutorials/lessons/200/argocd)

This folder is reserved for **optional thin modules** later (EBS CSI extras, IRSA for backups, etc.) if lesson 200 does not cover them.

## Layout (placeholders)

```text
terraform/
  README.md
  modules/
    eks-addons/     # optional future: EBS CSI / StorageClass helpers
    postgres-ha/    # optional future: rarely needed — prefer Argo CD Helm apps
  envs/
    dev/            # optional root module wiring
```

## Rules

1. Prove local Phase 2 (Helm + Argo CD) before EKS.
2. Prefer Argo CD Applications under `envs/eks/` over Terraform `helm_release` for the Postgres operator/cluster (keeps GitOps consistent with lesson 200 apps).
3. Use Terraform for cluster/addons; use Argo CD for the Patroni/Zalando apps.
4. Do not commit tfstate or secret tfvars.

## Next

See [../docs/05-aws-terraform-roadmap.md](../docs/05-aws-terraform-roadmap.md).
