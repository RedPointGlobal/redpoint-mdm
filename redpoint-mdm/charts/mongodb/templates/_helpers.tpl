{{- define "custom.namespace" -}}
  {{- if .Values.global.namespace }}
    {{- .Values.global.namespace }}
  {{- else }}
    {{- .Release.Namespace }}
  {{- end }}
{{- end }}
