# Concepts: Techno Tim (Proxmox) → local Kubernetes

Source inspiration: Techno Tim’s “PostgreSQL Clustering the hard way” (PostgreSQL + etcd + Patroni + HAProxy + keepalived on VMs).

This project keeps the **ideas** and replaces the **host procedures** with Kubernetes objects and the Zalando Postgres Operator (Patroni inside Spilo pods).

## Component map

| Proxmox / Techno Tim | Local Kubernetes (this project) |
|----------------------|----------------------------------|
| 6 VMs with static IPs | Pods scheduled on kubeadm nodes; IPs are ephemeral |
| `apt install postgresql` + disable systemd | Container image; operator owns Postgres lifecycle |
| etcd on Postgres VMs (TLS, systemd) | Patroni DCS managed with the operator stack — **not** the Kubernetes control-plane etcd |
| `/etc/patroni/config.yml` + `systemctl` | Helm chart `postgres-ha` → `postgresql` CR + Zalando operator |
| HAProxy TCP + `GET /primary` | Operator Services (`*-master` / `*-repl`) selecting the current primary/replicas |
| keepalived VIP (`192.168.x.110`) | In-cluster DNS Service name; optional MetalLB/NodePort only for LAN clients |
| openssl + scp to `/etc/.../ssl` | Helm values + operator-managed Secrets |
| Manual install per VM | **Argo CD** Applications syncing Helm charts (GitOps) |
| pgAdmin → VIP | pgAdmin → `kubectl port-forward svc/... 5432:5432` or LAN VIP if you add MetalLB later |

## What you must not do

- **Do not** point Patroni at the Kubernetes apiserver etcd. That etcd is for cluster state only. Losing or overloading it takes down the whole Kubernetes control plane.
- **Do not** treat node IPs as stable database endpoints. Use Services.
- **Do not** copy tutorial example passwords into git.

## Failure domains (mental model)

```text
Techno Tim:
  Client → VIP (keepalived) → HAProxy → Patroni primary → replicas

This project (local):
  Git → Argo CD → Helm (operator + postgres-ha)
  Client → Service DNS (or port-forward) → Spilo/Patroni primary pod → replica pods
                 ↑
         Zalando operator reconciles desired state
```

## Original hard-way reference (learning only)

Useful to understand *why* pieces exist:

1. Consensus store (etcd) so nodes agree who is primary  
2. Patroni to run Postgres and perform failover  
3. A health-checked proxy so clients always hit the primary  
4. A floating VIP so the proxy itself is HA  

On Kubernetes, (3) and (4) collapse into Services (+ optional external LB). (1) and (2) live inside the operator/Spilo design instead of six hand-built VMs.

When executing this repo, follow [02-local-kubernetes.md](02-local-kubernetes.md) and [PHASES.md](../PHASES.md) — not the Proxmox apt/systemd steps as the happy path.
