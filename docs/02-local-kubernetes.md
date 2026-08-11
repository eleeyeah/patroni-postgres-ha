# Local Kubernetes runbook (Helm + Argo CD)

Target: kubeadm cluster under [`../../cluster/`](../../cluster/README.md).

Stack: **Argo CD** syncs:

1. Zalando **postgres-operator** Helm chart (upstream)
2. This repo’s **postgres-ha** Helm chart → `postgresql` CR (Spilo + Patroni)

Pattern matches [`tutorials/lessons/200`](../../tutorials/lessons/200/README.md) (App-of-Apps / ApplicationSet + Helm).

## Prerequisites

- [ ] `kubectl` context is your kubeadm cluster
- [ ] Nodes Ready
- [ ] StorageClass exists → set in [`../helm-charts/postgres-ha/values-local.yaml`](../helm-charts/postgres-ha/values-local.yaml)
- [ ] Argo CD installed (`kubectl get ns argocd`)
- [ ] Git remote configured ([`../argocd/REPO.md`](../argocd/REPO.md))

```bash
./scripts/check-prereqs.sh
```

## Deploy with Argo CD (preferred)

1. Confirm `repoURL` is `git@github.com:eleeyeah/patroni-postgres-ha.git` (see REPO.md).
2. Commit/push this repo so Argo CD can clone it.
3. Register the repo in Argo CD if private (SSH key / credential — same idea as lesson 200 `git-repo-secret.yaml`).
4. Apply project + apps:

```bash
kubectl apply -f argocd/project/project.yaml
kubectl apply -f argocd/project/applicationset.yaml
# optional App-of-Apps:
# kubectl apply -f argocd/root-app.yaml
```

5. In Argo CD UI/CLI, confirm:
   - `postgres-operator-local` Synced/Healthy (wave 0)
   - `postgres-ha-local` Synced/Healthy (wave 1)

6. Verify:

```bash
kubectl -n postgres-operator get pods
kubectl get crd postgresqls.acid.zalan.do
kubectl -n postgres-ha get postgresql,pods,svc,pvc
```

## Helm CLI (debug / bootstrap without GitOps)

Only if Argo CD is not ready yet:

```bash
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator
helm upgrade --install postgres-operator postgres-operator-charts/postgres-operator \
  -n postgres-operator --create-namespace

helm upgrade --install postgres-ha ./helm-charts/postgres-ha \
  -n postgres-ha --create-namespace \
  -f ./helm-charts/postgres-ha/values-local.yaml
```

Prefer switching to Argo CD Applications under `envs/local/` afterward so Git remains the source of truth.

## Connecting (replaces keepalived VIP)

```bash
kubectl -n postgres-ha get svc
kubectl -n postgres-ha port-forward svc/<master-service> 5432:5432
```

Credentials: operator-managed Secret in `postgres-ha` (do not commit).

Patroni:

```bash
kubectl -n postgres-ha exec -it <pod> -- patronictl list
```

## Failover smoke test

1. Note master from `patronictl list`.
2. Delete master pod (or use operator switchover).
3. Confirm new master; port-forward to master Service still works.

## Reset (lab)

Delete the Argo CD Application or:

```bash
helm -n postgres-ha uninstall postgres-ha
kubectl -n postgres-ha delete pvc --all   # wipes data
```

## Optional LAN VIP

MetalLB / NodePort in front of the master Service — not required for port-forward or in-cluster clients.
