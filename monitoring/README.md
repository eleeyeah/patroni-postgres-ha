# Monitoring stubs (Phase 3)

Placeholders only. Apply after a Prometheus Operator (or equivalent) is installed and Phase 2 Postgres is running.

## Files

| File | Purpose |
|------|---------|
| [servicemonitor.yaml.stub](servicemonitor.yaml.stub) | Example ServiceMonitor — rename/adjust labels to match your Spilo Services |
| [alert-ideas.md](alert-ideas.md) | Suggested alert expressions (human checklist) |

## Enable later

1. Confirm scrape labels/ports on Postgres pods/Services.
2. Copy stub → `servicemonitor.yaml`, fix `selector` / `namespaceSelector`.
3. `kubectl apply -f servicemonitor.yaml`
4. Verify targets in Prometheus UI.

See [../docs/03-monitoring.md](../docs/03-monitoring.md).
