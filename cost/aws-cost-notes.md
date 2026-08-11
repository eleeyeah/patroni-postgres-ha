# AWS cost notes (for Phase 5 Terraform)

- [ ] Choose gp3 size/IOPS/throughput for Postgres PVCs
- [ ] Prefer on-demand (or reserved) nodes for DB workloads; **no Spot for primary**
- [ ] Decide single-AZ lab vs multi-AZ HA (volumes are AZ-scoped)
- [ ] Account for NLB hourly + LCU cost if using LoadBalancer Service
- [ ] Set backup/WAL retention lifecycle on S3
- [ ] Destroy or scale down `envs/dev` when idle
- [ ] Align Terraform variable defaults with [resource-hints.yaml](resource-hints.yaml)
