# Argo CD — Patroni Postgres HA

GitOps layout mirrors [`tutorials/lessons/200/argocd`](../../tutorials/lessons/200/argocd) (App-of-Apps + ApplicationSet).

## Layout

```text
argocd/
  root-app.yaml              # App-of-Apps → argocd/project
  project/
    project.yaml             # AppProject
    applicationset.yaml      # syncs envs/<env>/*
  REPO.md                    # set your git repoURL once
envs/
  local/                     # kubeadm
    postgres-operator/application.yaml
    postgres-ha/application.yaml
  eks/                       # after lessons/200 EKS exists
    postgres-operator/application.yaml
    postgres-ha/application.yaml
```

## Bootstrap order

1. Install Argo CD on the cluster (local Helm, or Terraform on EKS via [`tutorials/lessons/200/terraform/11-argocd.tf`](../../tutorials/lessons/200/terraform/11-argocd.tf)).
2. Edit **every** `repoURL` (see [REPO.md](REPO.md)) to the git remote that contains this project.
3. Register the git repo in Argo CD (SSH deploy key or HTTPS token) if private — same pattern as lesson 200 `git-repo-secret.yaml`.
4. Apply project + ApplicationSet (or root app):

```bash
# From repo root that contains patroni-postgres-ha/
kubectl apply -f patroni-postgres-ha/argocd/project/project.yaml
kubectl apply -f patroni-postgres-ha/argocd/project/applicationset.yaml

# Or App-of-Apps:
kubectl apply -f patroni-postgres-ha/argocd/root-app.yaml
```

5. Sync waves: operator (`wave 0`) before cluster (`wave 1`).
6. Set `volume.storageClass` in Helm values before expecting PVCs to bind.

## Sync waves

| App | Wave | Namespace |
|-----|------|-----------|
| postgres-operator | 0 | postgres-operator |
| postgres-ha | 1 | postgres-ha |
