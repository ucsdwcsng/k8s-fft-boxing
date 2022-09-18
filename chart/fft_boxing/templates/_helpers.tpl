{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fft_boxing.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fft_boxing.labels" -}}
helm.sh/chart: {{ include "fft_boxing.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: "v{{ .Chart.AppVersion }}"
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
