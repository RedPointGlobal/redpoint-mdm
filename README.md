Redpoint Master Data Management (MDM) is a data stewardship system for managing the Golden Record: a single, accurate, and always up-to-date view of your most critical data. The MDM system includes a variety of capabilities for controlling your data,

MDM is packaged and distributed as docker container images that are hosted in the Redpoint Global private repository in Docker Hub.

![image-20220119-194321](https://user-images.githubusercontent.com/42842390/157572766-5dbb1230-3a91-49a3-a0f1-dc889fb214bc.png)

This documentation will show you how to:

- Install or upgrade MDM in Kubernetes using HELM.
- Expose the MDM Web User Interface
- Connect MDM to Redpoint Data Management (RPDM) using the MDM Tools

Before you install MDM, you must:

1. Install kubectl. ( https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ )
2. Install HELM. ( https://helm.sh/docs/intro/install/ )
3. Have a Kubernetes solution available to use. ( https://kubernetes.io/docs/setup/production-environment/turnkey-solutions/ )
4. Clone this repository ( git clone https://github.com/RedPointGlobal/rp-mdm.git ) 
5. Provide Redpoint Support with your docker hub ID so they can grant you permissions to pull the MDM container images
