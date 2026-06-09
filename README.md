![redpoint_logo](chart/images/redpoint.png)
## Master Data Management (MDM) | Deployment on Kubernetes

Redpoint® Master Data Management (MDM) manages the Golden Record: a single, accurate, and always up-to-date view of your most critical data. MDM gives you the capabilities to match, de-duplicate, steward, and govern that data across your organization.

This chart deploys MDM on Kubernetes using Helm. It targets Microsoft Azure.

## Choose Your Path

| | New Installation | Connect to RPDM | Upgrading |
|:---|:---|:---|:---|
| **Guide** | [Installation](docs/installation.md) | [RPDM Integration](docs/rpdm-integration.md) | [Operations](docs/operations.md) |
| **When to use** | New cluster and MongoDB, deploying MDM for the first time | Wire MDM into Redpoint Data Management once it is running | Move an existing release to a newer chart version |
| **Database** | You supply an external MongoDB connection string | Reuses the running deployment | Existing configuration is reused |

---

## Guides

| Guide | Description |
|:------|:------------|
| [Installation](docs/installation.md) | Prerequisites, system requirements, install procedure, endpoints, activation |
| [Production Configuration](docs/production.md) | External MongoDB, ingress options, Azure cloud identity, scaling and resources |
| [RPDM Integration](docs/rpdm-integration.md) | Connect MDM to Redpoint Data Management (RPDM) |
| [Operations](docs/operations.md) | Upgrading and troubleshooting |

## Resources

- [Support](mailto:support@redpointglobal.com) (MDM application issues)
- [www.redpointglobal.com](https://www.redpointglobal.com)

---
<sub>Redpoint MDM v1.6.4 | [Support](mailto:support@redpointglobal.com) | [redpointglobal.com](https://www.redpointglobal.com)</sub>
