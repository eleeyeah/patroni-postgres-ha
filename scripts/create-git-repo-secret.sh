#!/usr/bin/env bash
# Build argocd/git-repo-secret.yaml from argocd/deploy-key (gitignored).
# Does not apply to the cluster — run: kubectl apply -f argocd/git-repo-secret.yaml
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

KEY_FILE="argocd/deploy-key"
OUT_FILE="argocd/git-repo-secret.yaml"
REPO_URL="git@github.com:eleeyeah/patroni-postgres-ha.git"
SECRET_NAME="patroni-postgres-ha-repo"

if [[ ! -f "$KEY_FILE" ]]; then
  echo "FAIL: missing $KEY_FILE"
  echo "Generate it first:"
  echo "  ssh-keygen -t ed25519 -C \"argocd@patroni-postgres-ha\" -f argocd/deploy-key -N \"\""
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "FAIL: kubectl not found in PATH"
  exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

kubectl create secret generic "$SECRET_NAME" \
  -n argocd \
  --from-file=sshPrivateKey="$KEY_FILE" \
  --from-literal=url="$REPO_URL" \
  --from-literal=type=git \
  --from-literal=insecure=false \
  --from-literal=enableLfs=false \
  --dry-run=client -o yaml >"$TMP"

# Ensure Argo CD repository label (works without kubectl label --local).
if grep -q '^  labels:' "$TMP"; then
  awk '
    BEGIN { done=0 }
    /^  labels:/ && !done {
      print
      print "    argocd.argoproj.io/secret-type: repository"
      done=1
      next
    }
    { print }
  ' "$TMP" >"$OUT_FILE"
else
  awk '
    BEGIN { done=0 }
    /^metadata:/ && !done {
      print
      print "  labels:"
      print "    argocd.argoproj.io/secret-type: repository"
      done=1
      next
    }
    { print }
  ' "$TMP" >"$OUT_FILE"
fi

echo "OK: wrote $OUT_FILE"
if command -v git >/dev/null 2>&1; then
  git check-ignore -v "$OUT_FILE" "$KEY_FILE" || true
fi
echo
echo "Next:"
echo "  kubectl apply -f $OUT_FILE"
echo "  kubectl -n argocd get secret $SECRET_NAME -o jsonpath='{.metadata.labels}' ; echo"
