# Phase 4 — Cost optimization

Cost on a homelab is mostly **hardware headroom** and **time**. On AWS it becomes **nodes + EBS + LB + control plane**. Optimize after you know the cluster works (Phase 2).

## Local (kubeadm)

### Right-size

| Knob | Guidance |
|------|----------|
| `numberOfInstances` | 3 for real HA quorum-style lab; use 2 only for tiny hardware (weaker HA story) |
| CPU / memory requests | Fit sum of pods on your workers without evicting system pods |
| Volume size | Start small (e.g. 10–20Gi) for lab; grow when needed |
| `shared_buffers` / Postgres params | Keep modest on laptops/NUC-class nodes |

Example requests live in [`../cost/resource-hints.yaml`](../cost/resource-hints.yaml) (documentation fragment — merge into CR when applying).

### Avoid waste

- Do not run a second full Postgres HA stack “for fun” on the same three nodes without measuring.
- Tear down lab clusters when idle (`kubectl delete postgresql ...`) if disk is tight.
- Prefer one StorageClass you understand over multiple provisional volumes.

## AWS preview (for Phase 5)

| Item | Note |
|------|------|
| EBS size / IOPS / throughput | Dominates stateful cost; match gp3 to need |
| Multi-AZ | Better HA; more cross-AZ traffic and volume complexity (EBS is AZ-scoped) |
| Spot instances | **Do not** put the primary on Spot; risky for stateful DB |
| Load balancer | NLB in front of master Service — small ongoing cost |
| Idle non-prod | Schedule shutdown or destroy envs when unused |
| Backup retention | WAL/basebackup to S3 — set lifecycle policies |

## Checklist

- [ ] Requests/limits set on Postgres pods
- [ ] PVC size justified
- [ ] Lab instance count matches hardware
- [ ] AWS notes captured for Terraform modules (no Spot primary, EBS class chosen)
- [ ] Non-prod teardown / retention policy written

Return to [PHASES.md](../PHASES.md#phase-4--cost-optimization).
