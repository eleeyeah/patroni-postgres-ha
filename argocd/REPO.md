# Git repository URL

**Git root:** this repository (`patroni-postgres-ha` itself).

```text
git@github.com:eleeyeah/patroni-postgres-ha.git
```

## Path convention (repo root = this folder)

| Source | path |
|--------|------|
| App-of-Apps project | `argocd/project` |
| ApplicationSet envs | `envs/{{env}}` |
| Helm chart postgres-ha | `helm-charts/postgres-ha` |

Files that must use the `repoURL` above:

- `argocd/root-app.yaml`
- `argocd/project/project.yaml` (`sourceRepos`)
- `argocd/project/applicationset.yaml`
- `envs/local/postgres-ha/application.yaml`
- `envs/eks/postgres-ha/application.yaml`

Operator apps use the Zalando Helm repo URL, not this git remote.
