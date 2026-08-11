{{/*
Expand chart name.
*/}}
{{- define "postgres-ha.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "postgres-ha.fullname" -}}
{{- default .Values.fullname .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "postgres-ha.labels" -}}
app.kubernetes.io/name: {{ include "postgres-ha.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: patroni-postgres-ha
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}
