Redpoint Master Data Management (MDM) is a data stewardship system for managing the Golden Record: a single, accurate, and always up-to-date view of your most critical data. The MDM system includes a variety of capabilities for controlling your data,

MDM is packaged and distributed as docker container images that are hosted in the Redpoint Global private repository in Docker Hub.

![Copy of Redpoint MDM](https://user-images.githubusercontent.com/42842390/157733682-2a0fe90e-7079-4790-856b-7866dec40d6b.jpeg)

This documentation will show you how to:

## Table of Contents

- [Install or upgrade MDM in Kubernetes using HELM](#Install-or-upgrade-mdm-in-kubernetes-using-helm)
  - [Prerequisites](#prerequisites)
  - [Expose the MDM Web UI](#expose-the-mdm-web-ui)
  - [Connect MDM to Redpoint Data Management (RPDM)](#connect-mdm-to-redpoint-data-management-(rpdm))
  - [Procedure](#procedure)
- [Upgrade MDM](#upgrade-mdm)

### Prerequisites

Before you install MDM, you must:

1. Install kubectl. ( https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ )
2. Install HELM. ( https://helm.sh/docs/intro/install/ )
3. Have a Kubernetes solution available to use. ( https://kubernetes.io/docs/setup/production-environment/turnkey-solutions/ )
4. Have a MongoDB database server available to use for the MDM application Databases. ( https://docs.mongodb.com/v4.4/installation/). This can also be a managed solution like mongo Atlas. (As of this writing, MDM has been tested on MongoDB version 4.4)
5. Clone this repository ( git clone https://github.com/RedPointGlobal/rp-mdm.git ) 
6. Provide Redpoint Support with your docker hub ID so they can grant you permissions to pull the MDM container images
