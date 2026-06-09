# Installation

Install Redpoint MDM on a Kubernetes cluster using Helm. This guide targets Microsoft Azure and an external MongoDB.

> **Demo vs Production:** the default values are suitable for a `DEMO` or `DEV` deployment. For production sizing, an external production-grade MongoDB, and ingress hardening, see [Production Configuration](production.md).

## Prerequisites

Before you install MDM, you must:

1. Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).
2. Install [Helm](https://helm.sh/docs/intro/install/).
3. Have a Kubernetes cluster available ([turnkey solutions](https://kubernetes.io/docs/setup/production-environment/turnkey-solutions/)).
4. Have a [MongoDB](https://www.mongodb.com/docs/manual/installation/) server available for the MDM databases. A managed service such as MongoDB Atlas works well.
5. Have access to the Redpoint container registry. Contact Redpoint Support to be granted pull permissions for the MDM images.
6. Have a license key to activate MDM. Contact Redpoint Support for an activation key.

## System Requirements

**MongoDB sizing**

| Data size | Memory |
|:---|:---|
| < 1 million records | 4 GB |
| 1 - 10 million records | 8 - 16 GB |
| > 10 million records | Size memory to keep the working index set in memory |

Use SSD disks for best IO performance.

**Kubernetes cluster sizing**

- A node pool with 2-3 nodes for high availability
- 8 vCPUs and 32 GB memory per node
- 20 GB or more free disk space per node

## Install Procedure

**1. Clone the repository and connect to your target cluster**

```sh
git clone https://github.com/RedPointGlobal/redpoint-mdm.git
cd redpoint-mdm
```

**2. Create the namespace**

```sh
kubectl create namespace redpoint-mdm
```

**3. Create the image pull secret**

The chart expects an image pull secret whose name matches `global.deployment.images.imagePullSecret.name` (default `redpoint-mdm`). Use the registry credentials provided by Redpoint Support:

```sh
kubectl create secret docker-registry redpoint-mdm \
  --docker-server=rg1acrpub.azurecr.io \
  --docker-username=$registry_username \
  --docker-password=$registry_password \
  --namespace redpoint-mdm
```

If your registry does not require authentication, set `global.deployment.images.imagePullSecret.enabled: false` in `values.yaml` and skip this step.

**4. Create the TLS secret**

The default nginx ingress controller terminates TLS for your custom domain using a secret named to match `ingress.tlsSecretName` (default `ingress-tls`). Without it, the Web UI returns `502 Bad Gateway`.

```sh
kubectl create secret tls ingress-tls \
  --cert=$your_tls_cert --key=$your_tls_key \
  --namespace redpoint-mdm
```

To use a different ingress controller instead, see [Production Configuration → Ingress](production.md#ingress).

**5. Create the MongoDB secret**

MDM reads its MongoDB connection string from a Kubernetes secret that **you create out-of-band**. Sensitive values are never placed in `values.yaml`. The secret name must match `cloudIdentity.secretsManagement.secretName` (default `redpoint-mdm-secrets`) and must contain the key `MONGO_CONNECTION_STRING`:

```sh
kubectl create secret generic redpoint-mdm-secrets \
  --from-literal=MONGO_CONNECTION_STRING='mongodb://<user>:<password>@<host>:27017/admin?authSource=admin' \
  --namespace redpoint-mdm
```

The chart references this secret but never creates it or stores secret values. If the secret is missing, the MDM pods fail to start with `CreateContainerConfigError`.

**6. Install MDM**

```sh
kubectl config set-context --current --namespace=redpoint-mdm
helm install redpoint-mdm chart/ --values values.yaml
```

A successful install prints:

```
NAME: redpoint-mdm
STATUS: deployed
REVISION: 1
NOTES:
********************************* SUCCESS! ************************************************************
MDM has been successfully installed in your cluster.
```

Allow a few minutes for all MDM services to start.

## Endpoints

The default installation exposes the MDM Web UI through the bundled nginx ingress controller. Retrieve the Web UI host:

```sh
kubectl get ingress --namespace redpoint-mdm
```

It returns a host of the form:

```
rp-mdm-ui.example.com
```

The Core and Authentication services are reached through the ingress at the hosts you configured (`ingress.hosts.core` / `ingress.hosts.authentication` joined with `ingress.domain`). These endpoints are used to connect MDM to Redpoint Data Management (see [RPDM Integration](rpdm-integration.md)) and appear alongside the Web UI host in the same `kubectl get ingress` output. The underlying Kubernetes services are internal (ClusterIP); the ingress fronts them.

## Activation

Once MDM is installed and you have your activation key from Redpoint Support, activate MDM. Log in to the Web UI with the default username `system` and password `system`, then enter the activation license:

```
Demo license URL:        trial-license
Production license URL:  https://qlm1.net/redpointglobal/qlmlicenseserver/qlmservice.asmx
Public Key:              Same as the activation key
Product ID:              Prod or Trial depending on your activation key
```

![activation](https://user-images.githubusercontent.com/42842390/157773834-f2fe34ed-afb5-4d5d-af22-2cc898158846.png)

After successful activation you should see the Welcome page:

![welcome](https://user-images.githubusercontent.com/42842390/157773845-a1a972e6-f29b-4a20-a8d3-3560a9f84514.png)

---
<sub>[Back to README](../README.md) | [Support](mailto:support@redpointglobal.com)</sub>
