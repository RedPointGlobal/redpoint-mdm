# Migrate MDM from Docker to Kubernetes

While MDM can run on virtual machines using Docker, Redpoint recommends migrating production workloads to Kubernetes. Redpoint does not support MDM production workloads on Docker.

Use a blue/green approach for a smooth transition with minimal downtime:

1. **Set up a Kubernetes cluster** as described in [Installation → Prerequisites](installation.md#prerequisites).
2. **Set up a new MongoDB server** as described in [Installation → Prerequisites](installation.md#prerequisites).
3. **Deploy MDM** to the Kubernetes cluster as described in [Installation](installation.md).
4. **Copy the system database.** Copy all Mongo collections from the `rpmdm_system` database to `rpmdm_system` on the new MongoDB server.
5. **Copy user databases.** Copy all user-created MDM databases from the old MongoDB server to the new one. A tool such as [Studio 3T](https://studio3t.com/) works well.
6. **Test** the new deployment thoroughly to confirm it functions correctly.
7. **Switch traffic** to the new deployment once it passes testing.
8. **Decommission** the old Docker virtual machines once the new deployment is running smoothly.

---
<sub>[Back to README](../README.md) | [Support](mailto:support@redpointglobal.com)</sub>
