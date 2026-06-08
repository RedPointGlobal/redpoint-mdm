{{- define "mdm.serviceDefaults" -}}
enabled: true
replicas: 1
resources:
  enabled: true
  requests:
    cpu: 100m
    memory: 1Gi
  limits:
    memory: 1Gi
customLabels: {}
customAnnotations: {}
customMetrics:
  enabled: false
logging:
  trace: false
  enabled: false
probes:
  enabled: false
  livenessProbe:
    initialDelaySeconds: 30
    periodSeconds: 10
    failureThreshold: 3
  readinessProbe:
    initialDelaySeconds: 20
    periodSeconds: 15
    failureThreshold: 5
  startupProbe:
    initialDelaySeconds: 10
    periodSeconds: 10
    failureThreshold: 30
  podDisruptionBudget:
    enabled: false
    maxUnavailable: 0
autoscaling:
  enabled: false
  type: hpa
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 70
securityContext:
  enabled: true
  runAsUser: 7777
  runAsGroup: 7777
  fsGroup: 7777
  runAsNonRoot: true
  readOnlyRootFilesystem: true
  privileged: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  supplementalGroups:
    - 4000
    - 5000
{{- end -}}
