# Operations

## Upgrading

If you deployed MDM with this Helm chart, upgrading to a newer version is straightforward.

**1. Fetch the latest chart**

```sh
git pull
```

**2. Run the upgrade**

Reuse your release name and value overrides:

```sh
helm upgrade redpoint-mdm chart/ --values values.yaml
```

Replace the release name and values file with your own if they differ. The upgrade applies the new chart version and any configuration changes.

## Troubleshooting

**Unable to log in to the Web UI**

Almost always a network connectivity issue. If MDM cannot reach the MongoDB server, login fails. Confirm by checking the logs for the Core and Authentication pods:

```sh
kubectl logs -n redpoint-mdm deploy/rp-mdm-core
kubectl logs -n redpoint-mdm deploy/rp-mdm-authentication
```

Once connectivity is restored, you can log in and connect MDM to RPDM.

**nginx `502 Bad Gateway` when accessing the Web UI**

The default installation requires a TLS secret named to match `ingress.tlsSecretName` (default `ingress-tls`). If it is missing, nginx cannot route Web UI requests. Create the secret with your certificate data to resolve it:

```sh
kubectl create secret tls ingress-tls \
  --cert=$your_tls_cert --key=$your_tls_key \
  --namespace redpoint-mdm
```

**Pods stuck in `CreateContainerConfigError`**

The MongoDB connection secret is missing or misnamed. The chart references a secret named to match `cloudIdentity.secretsManagement.secretName` (default `redpoint-mdm-secrets`) containing the key `MONGO_CONNECTION_STRING`. Create it (see [Installation](installation.md#install-procedure)) and confirm the name and key:

```sh
kubectl get secret redpoint-mdm-secrets -n redpoint-mdm -o jsonpath='{.data.MONGO_CONNECTION_STRING}' | base64 -d
```

**General status checks**

```sh
kubectl get pods -n redpoint-mdm
kubectl get events -n redpoint-mdm --sort-by='.lastTimestamp'
```

---
<sub>[Back to README](../README.md) | [Support](mailto:support@redpointglobal.com)</sub>
