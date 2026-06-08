# Production Configuration

The default values are suitable for `DEMO` or `DEV`. For production, configure an external MongoDB, your ingress strategy, Azure cloud identity, and per-service scaling.

## MongoDB

MDM requires an external, production-grade MongoDB.

### Secrets

MDM's MongoDB connection string is sensitive and is **never stored in `values.yaml`**. You create a Kubernetes secret out-of-band and the chart references it by name. The chart never creates the secret or holds its value.

```yaml
cloudIdentity:
  secretsManagement:
    # Name of the secret you create. Must contain key MONGO_CONNECTION_STRING.
    secretName: redpoint-mdm-secrets
```

Create the secret before installing or upgrading:

```sh
kubectl create secret generic redpoint-mdm-secrets \
  --from-literal=MONGO_CONNECTION_STRING='mongodb://<user>:<password>@<host>:27017/admin?authSource=admin' \
  --namespace redpoint-mdm
```

Manage the secret with your own tooling (External Secrets Operator, CSI driver, sealed-secrets, GitOps, etc.). Kubernetes secrets are the only supported provider.

## Ingress

The default installation deploys an nginx ingress controller that exposes the MDM Web UI on `ingress.domain`.

```yaml
ingress:
  controller:
    enabled: true
  mode: public            # 'private' for an internal load balancer
  domain: example.com
  className: nginx-redpoint-mdm
  tlsSecretName: ingress-tls
```

To bring your own ingress controller, disable the bundled one and reuse your existing class:

```yaml
ingress:
  controller:
    enabled: false
  className: <your-ingress-class>
```

### Private ingress (Azure)

For an internal load balancer or Azure Private Link, set `mode: private` and supply the subnet:

```yaml
ingress:
  mode: private
  subnetName: <my-ingress-subnet-name>
  privateLink:
    azure:
      enabled: true
```

## Azure cloud identity

The chart targets Azure (`global.deployment.platform: azure`). Workloads authenticate to Azure services with Workload Identity:

```yaml
cloudIdentity:
  enabled: true
  provider: Azure
  azureSettings:
    credentialsType: workloadIdentity
    managedIdentityClientId: <your-managed-identity-client-id>
```

`managedIdentityClientId` is required when `credentialsType: workloadIdentity`. The chart annotates each ServiceAccount with the client ID and labels the pods with `azure.workload.identity/use: "true"`.

## Scaling and resources

Each service (`authService`, `coreService`, `logService`, `permissionService`, `webUI`, `userService`) inherits common defaults and accepts per-service overrides. Common settings:

```yaml
coreService:
  replicas: 2
  resources:
    requests:
      cpu: 250m
      memory: 4Gi
    limits:
      memory: 4Gi
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 5
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 70
  probes:
    enabled: true
    podDisruptionBudget:
      enabled: true
      maxUnavailable: 1
```

When `autoscaling.enabled: true`, a HorizontalPodAutoscaler is created and the static `replicas` value is not used. When `podDisruptionBudget.enabled: true`, a PodDisruptionBudget is created.

Pods run with a hardened security context by default (non-root UID/GID 7777, read-only root filesystem, dropped capabilities, `seccompProfile: RuntimeDefault`). Override per service under `securityContext` if required.

---
<sub>[Back to README](../README.md) | [Support](mailto:support@redpointglobal.com)</sub>
