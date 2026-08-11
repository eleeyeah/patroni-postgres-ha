# Connect private GitHub repo to Argo CD (Secret method)

Same idea as lesson 200 `git-repo-secret.yaml`. Do **not** commit the real secret or private key.

## Step 1 — Generate a deploy key (lab machine)

```bash
cd /home/ih-entpr/Documents/scripts/patroni-postgres-ha

ssh-keygen -t ed25519 -C "argocd@patroni-postgres-ha" \
  -f argocd/deploy-key -N ""
```

This creates (gitignored):

- `argocd/deploy-key` — private (goes into the Secret)
- `argocd/deploy-key.pub` — public (goes to GitHub)

Show the public key:

```bash
cat argocd/deploy-key.pub
```

## Step 2 — Add deploy key on GitHub

1. Open https://github.com/eleeyeah/patroni-postgres-ha/settings/keys  
2. **Add deploy key**  
3. Title: `argocd-local`  
4. Paste contents of `argocd/deploy-key.pub`  
5. Leave **Allow write access** unchecked (read-only is enough)  
6. Add key  

## Step 3 — Build the Secret file (local only)

```bash
cd /home/ih-entpr/Documents/scripts/patroni-postgres-ha

./scripts/create-git-repo-secret.sh
git check-ignore -v argocd/git-repo-secret.yaml
```

This writes **gitignored** `argocd/git-repo-secret.yaml` from `argocd/deploy-key` (kubectl dry-run + Argo repository label). Do not commit that file.

(`argocd/git-repo-secret.yaml.example` is documentation only.)

## Step 4 — Apply to the cluster

```bash
kubectl apply -f argocd/git-repo-secret.yaml
kubectl -n argocd get secret patroni-postgres-ha-repo \
  -o jsonpath='{.metadata.labels}' ; echo
```

You should see `argocd.argoproj.io/secret-type: repository`.

## Step 5 — Verify in Argo CD UI

Refresh **Settings → Repositories**.  
Repo `git@github.com:eleeyeah/patroni-postgres-ha.git` should show **Successful** (or Connection Status OK).

CLI alternative:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:80
# then in another terminal, if argocd CLI is installed:
argocd repo list
```

## Step 6 — Deploy apps (after repo is Successful)

```bash
git push   # if local commits not on GitHub yet
kubectl apply -f argocd/project/project.yaml
kubectl apply -f argocd/project/applicationset.yaml
kubectl -n argocd get applicationset,app
```
