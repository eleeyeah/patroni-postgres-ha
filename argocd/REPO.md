# Git repository URL

Argo CD Applications need a **git remote** that contains the `patroni-postgres-ha/` tree (same idea as lesson 200 pointing at `antonputra/k8s` / `tutorials`).

Replace this placeholder everywhere it appears:

```text
git@github.com:YOUR_ORG/YOUR_REPO.git
```

Search/replace in:

- `argocd/root-app.yaml`
- `argocd/project/applicationset.yaml`
- `envs/local/*/application.yaml`
- `envs/eks/*/application.yaml`

**Path convention** (repo root = parent of `patroni-postgres-ha/`):

| Source | path |
|--------|------|
| App-of-Apps project | `patroni-postgres-ha/argocd/project` |
| ApplicationSet envs | `patroni-postgres-ha/envs/{{env}}` |
| Helm chart postgres-ha | `patroni-postgres-ha/helm-charts/postgres-ha` |

If this entire `scripts/` directory is the git root, those paths are correct as written.
