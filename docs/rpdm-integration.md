# Connect MDM to Redpoint Data Management (RPDM)

To connect MDM to RPDM you need the IP addresses of the MDM Core and Authentication services, which are exposed over TCP by `LoadBalancer` services.

**1. Retrieve the service IP addresses**

```sh
kubectl get service rp-mdm-core-tcp            # MDM Core service (port 9902)
kubectl get service rp-mdm-authentication-tcp  # MDM Authentication service (port 9901)
```

**2. Install the MDM tools in RPDM**

1. Download the MDM tools JAR from the URL provided by Redpoint Support. The filename is of the form `mdm-connectors-*-shaded.jar`.
2. Place the JAR into the `\java_plugins` folder in the Redpoint Data Management installation folder.
3. In the RPDM client, click the Palette menu button at the top of the tool palette and select **Reset Palette**. The tools appear in the Master Data tool group.
4. Click the Repository tab and go to **Settings > Tools**.
5. Close and re-open any projects that were active before installing the MDM tools JAR.

**3. Configure the MDM connection**

Click the MDM tab and enter your server and authentication endpoints:

```
Authentication Server URL: http://<MDM Authentication service IP>:9901/mdm
MDM Server URL:            http://<MDM Core service IP>:9902/mdm

Example:
Authentication Server URL: http://10.60.0.20:9901/mdm
MDM Server URL:            http://10.60.0.30:9902/mdm
```

![rpdm-mdm-settings](https://user-images.githubusercontent.com/42842390/223878996-04c82cf7-531e-4568-9e6f-8390181628fa.png)

---
<sub>[Back to README](../README.md) | [Support](mailto:support@redpointglobal.com)</sub>
