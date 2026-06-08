{{- define "mdm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mdm.service" -}}
{{- $defaults := fromYaml (include "mdm.serviceDefaults" .root) -}}
{{- $override := .override | default dict -}}
{{- toYaml (mergeOverwrite $defaults $override) -}}
{{- end -}}

{{- define "mdm.validateConfig" -}}
{{- if not .Values.cloudIdentity.secretsManagement.secretName -}}
{{- fail "Invalid config: cloudIdentity.secretsManagement.secretName is required. Create the Kubernetes secret out-of-band (key MONGO_CONNECTION_STRING) and set its name here." -}}
{{- end -}}
{{- if and .Values.cloudIdentity.enabled (eq .Values.cloudIdentity.azureSettings.credentialsType "workloadIdentity") (not .Values.cloudIdentity.azureSettings.managedIdentityClientId) -}}
{{- fail "Invalid config: cloudIdentity.azureSettings.managedIdentityClientId is required when credentialsType=workloadIdentity" -}}
{{- end -}}
{{- end -}}

{{- define "mdm.labels" -}}
app: {{ .name }}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .component }}
app.kubernetes.io/part-of: redpoint-mdm
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
app.kubernetes.io/version: {{ .root.Values.global.deployment.images.tag | quote }}
helm.sh/chart: {{ include "mdm.chart" .root }}
{{- end -}}

{{- define "mdm.selectorLabels" -}}
app: {{ .name }}
{{- end -}}

{{- define "mdm.image" -}}
{{- printf "%s:%s" .repo .root.Values.global.deployment.images.tag -}}
{{- end -}}

{{- define "mdm.imagePullSecrets" -}}
{{- if .root.Values.global.deployment.images.imagePullSecret.enabled }}
imagePullSecrets:
- name: {{ .root.Values.global.deployment.images.imagePullSecret.name }}
{{- end }}
{{- end -}}

{{- define "mdm.cloudidentity.saAnnotations" -}}
{{- if eq .root.Values.global.deployment.platform "azure" }}
{{- if .root.Values.cloudIdentity.enabled }}
{{- if eq .root.Values.cloudIdentity.azureSettings.credentialsType "workloadIdentity" }}
azure.workload.identity/client-id: {{ .root.Values.cloudIdentity.azureSettings.managedIdentityClientId | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "mdm.cloudidentity.podLabels" -}}
{{- if eq .root.Values.global.deployment.platform "azure" }}
{{- if eq .root.Values.cloudIdentity.azureSettings.credentialsType "workloadIdentity" }}
azure.workload.identity/use: "true"
{{- end }}
{{- end }}
{{- end -}}

{{- define "mdm.pod.securityContext" -}}
securityContext:
  runAsUser: {{ .sc.runAsUser }}
  runAsGroup: {{ .sc.runAsGroup }}
  fsGroup: {{ .sc.fsGroup }}
  runAsNonRoot: {{ .sc.runAsNonRoot }}
  seccompProfile:
    type: RuntimeDefault
  {{- with .sc.supplementalGroups }}
  supplementalGroups:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}

{{- define "mdm.container.securityContext" -}}
securityContext:
  privileged: {{ .sc.privileged }}
  allowPrivilegeEscalation: {{ .sc.allowPrivilegeEscalation }}
  readOnlyRootFilesystem: {{ .sc.readOnlyRootFilesystem }}
  {{- with .sc.capabilities }}
  capabilities:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}

{{- define "mdm.resources" -}}
{{- if .cfg.resources.enabled }}
resources:
  {{- if and .cfg.resources.limits (ne (.cfg.resources.limits.enabled | toString) "false") }}
  limits:
    {{- with .cfg.resources.limits.cpu }}
    cpu: {{ . }}
    {{- end }}
    {{- with .cfg.resources.limits.memory }}
    memory: {{ . }}
    {{- end }}
  {{- end }}
  {{- if and .cfg.resources.requests (ne (.cfg.resources.requests.enabled | toString) "false") }}
  requests:
    {{- with .cfg.resources.requests.cpu }}
    cpu: {{ . }}
    {{- end }}
    {{- with .cfg.resources.requests.memory }}
    memory: {{ . }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "mdm.probes" -}}
{{- if .cfg.probes.enabled }}
readinessProbe:
  httpGet:
    path: {{ .path }}
    port: http
  initialDelaySeconds: {{ .cfg.probes.readinessProbe.initialDelaySeconds }}
  periodSeconds: {{ .cfg.probes.readinessProbe.periodSeconds }}
  failureThreshold: {{ .cfg.probes.readinessProbe.failureThreshold }}
livenessProbe:
  httpGet:
    path: {{ .path }}
    port: http
  initialDelaySeconds: {{ .cfg.probes.livenessProbe.initialDelaySeconds }}
  periodSeconds: {{ .cfg.probes.livenessProbe.periodSeconds }}
  failureThreshold: {{ .cfg.probes.livenessProbe.failureThreshold }}
startupProbe:
  httpGet:
    path: {{ .path }}
    port: http
  initialDelaySeconds: {{ .cfg.probes.startupProbe.initialDelaySeconds }}
  periodSeconds: {{ .cfg.probes.startupProbe.periodSeconds }}
  failureThreshold: {{ .cfg.probes.startupProbe.failureThreshold }}
{{- end }}
{{- end -}}

{{- define "mdm.scheduling" -}}
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: {{ .name }}
          topologyKey: kubernetes.io/hostname
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: {{ .name }}
{{- if .root.Values.nodeSelector.enabled }}
nodeSelector:
  {{ .root.Values.nodeSelector.key }}: {{ .root.Values.nodeSelector.value }}
{{- end }}
{{- if .root.Values.tolerations.enabled }}
tolerations:
  - effect: NoSchedule
    key: {{ .root.Values.nodeSelector.key }}
    operator: Equal
    value: {{ .root.Values.nodeSelector.value }}
{{- end }}
{{- end -}}

{{- define "mdm.podAnnotations" -}}
{{- with .cfg.customAnnotations }}
{{- toYaml . }}
{{- end }}
{{- if .cfg.customMetrics.enabled }}
prometheus.io/scrape: {{ .cfg.customMetrics.prometheus_scrape | default "true" | quote }}
prometheus.io/port: {{ .port | quote }}
prometheus.io/path: "/metrics"
{{- end }}
{{- end -}}
