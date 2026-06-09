# Connect MDM to Redpoint Data Management (RPDM)

RPDM connects to MDM through the **ingress endpoints** for the Core and Authentication services. The Core and Authentication Kubernetes services are internal (ClusterIP); the ingress fronts them, so RPDM connects to the ingress hostnames, not to pod or service IPs.

The hostnames are built from your ingress values: `ingress.hosts.authentication` and `ingress.hosts.core`, each joined with `ingress.domain`.

**1. Find the MDM endpoints**

```sh
kubectl get ingress -n redpoint-mdm
```

The configured hosts appear under `HOSTS`, for example:

```
rp-mdm-authentication.example.com   # Authentication
rp-mdm-core.example.com             # Core
```

**2. Install the MDM tools in RPDM**

1. Download the MDM tools JAR from the URL provided by Redpoint Support. The filename is of the form `mdm-connectors-*-shaded.jar`.
2. Place the JAR into the `\java_plugins` folder in the Redpoint Data Management installation folder.
3. In the RPDM client, click the Palette menu button at the top of the tool palette and select **Reset Palette**. The tools appear in the Master Data tool group.
4. Click the Repository tab and go to **Settings > Tools**.
5. Close and re-open any projects that were active before installing the MDM tools JAR.

**3. Configure the MDM connection**

Click the MDM tab and enter the ingress endpoints. The `/mdm` path is required, and you do not append a port - the ingress routes to the correct service. Use `https` when TLS is configured on the ingress (the default), or `http` otherwise:

```
Authentication Server URL: https://<ingress.hosts.authentication>.<ingress.domain>/mdm
MDM Server URL:            https://<ingress.hosts.core>.<ingress.domain>/mdm

Example:
Authentication Server URL: https://rp-mdm-authentication.example.com/mdm
MDM Server URL:            https://rp-mdm-core.example.com/mdm
```

![rpdm-mdm-settings](https://user-images.githubusercontent.com/42842390/223878996-04c82cf7-531e-4568-9e6f-8390181628fa.png)

---
<sub>[Back to README](../README.md) | [Support](mailto:support@redpointglobal.com)</sub>
