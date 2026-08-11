#!/usr/bin/env bash
# Check local cluster readiness for Patroni Postgres HA (Helm + Argo CD).
# Does not install or apply anything.
set -euo pipefail

echo "==> kubectl availability"
if ! command -v kubectl >/dev/null 2>&1; then
  echo "FAIL: kubectl not found in PATH"
  exit 1
fi
echo "OK: kubectl present"

echo "==> helm availability"
if ! command -v helm >/dev/null 2>&1; then
  echo "WARN: helm not found (Argo CD can still deploy Helm charts; CLI useful for debug)"
else
  echo "OK: helm present"
fi

echo "==> current context"
CONTEXT="$(kubectl config current-context 2>/dev/null || true)"
if [[ -z "${CONTEXT}" ]]; then
  echo "FAIL: no kubectl context configured"
  exit 1
fi
echo "OK: context=${CONTEXT}"

echo "==> nodes"
if ! kubectl get nodes -o wide; then
  echo "FAIL: cannot list nodes"
  exit 1
fi

NOT_READY="$(kubectl get nodes --no-headers 2>/dev/null | awk '$2 != "Ready" {print $1}' || true)"
if [[ -n "${NOT_READY}" ]]; then
  echo "WARN: nodes not Ready: ${NOT_READY}"
else
  echo "OK: all listed nodes are Ready"
fi

echo "==> StorageClasses"
if kubectl get storageclass >/dev/null 2>&1; then
  kubectl get storageclass
  COUNT="$(kubectl get storageclass --no-headers 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "${COUNT}" == "0" ]]; then
    echo "WARN: no StorageClass — set one and update helm-charts/postgres-ha/values-local.yaml"
  else
    echo "OK: ${COUNT} StorageClass(es) — set volume.storageClass in values-local.yaml"
  fi
else
  echo "WARN: unable to list StorageClasses"
fi

echo "==> Argo CD namespace"
if kubectl get ns argocd >/dev/null 2>&1; then
  echo "OK: namespace argocd exists"
  kubectl -n argocd get deploy 2>/dev/null | head -20 || true
else
  echo "WARN: namespace argocd missing — install Argo CD before applying argocd/project apps"
fi

echo "==> Zalando postgresql CRD"
if kubectl get crd postgresqls.acid.zalan.do >/dev/null 2>&1; then
  echo "OK: postgresqls.acid.zalan.do present"
else
  echo "WARN: CRD missing — sync postgres-operator Argo CD app first (wave 0)"
fi

echo "==> done (prereq check only; nothing was applied)"
