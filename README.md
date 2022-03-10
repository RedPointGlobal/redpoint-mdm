Redpoint Master Data Management (MDM) is a data stewardship system for managing the Golden Record: a single, accurate, and always up-to-date view of your most critical data. The MDM system includes a variety of capabilities for controlling your data,

MDM is packaged and distributed as docker container images that are hosted in the Redpoint Global private repository in Docker Hub.

![NEW_MDM](https://user-images.githubusercontent.com/42842390/157733806-a9c6be0a-1888-4010-8602-dc1e70fd0b22.jpg)
This documentation will show you how to:

- [Install or upgrade MDM in Kubernetes using HELM](#Install-or-upgrade-mdm-in-kubernetes-using-helm)
  - [Prerequisites](#prerequisites)
  - [Access the MDM Web UI, Core and Authentication Server Endpoints ](#access-the-mdm-web-ui-core-and-authentication-server-endpoints)
  - [Connect MDM to Redpoint Data Management (RPDM)](#connect-mdm-to-redpoint-data-management-(rpdm))
  - [Procedure](#procedure)
- [Upgrade MDM](#upgrade-mdm)

### Prerequisites

Before you install MDM, you must:

1. Install kubectl. ( https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ )
2. Install HELM. ( https://helm.sh/docs/intro/install/ )
3. Have a Kubernetes solution available to use. ( https://kubernetes.io/docs/setup/production-environment/turnkey-solutions/ )
4. Have an Ingress Controller solution deployed in your Kubernetes cluster (https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
5. Have a MongoDB database server available to use for the MDM application Databases. ( https://docs.mongodb.com/v4.4/installation/). This can also be a managed solution like mongo Atlas. (As of this writing, MDM has been tested on MongoDB version 4.4)
6. Clone this repository ( git clone https://github.com/RedPointGlobal/rp-mdm.git ) 
7. Provide Redpoint Support with your docker hub ID so they can grant you permissions to pull the MDM container images

### Procedure

1. Clone this repository ( git clone https://github.com/RedPointGlobal/rp-mdm.git )
2. Connect to your Kubernetes Cluster
3. Create a namespace for MDM (HELM expects a namespace named redpoint-mdm to exist)
4. Create the following kubernetes secrets that MDM needs
     - mongodb-conn-string      : Secret that contains the mongodb connection string
     - docker-io                : Secret that contains your docker hub credentials
     - mdm-tls                  : Secret that contains your TLS certificate and private key to be used by the Ingress
5. Edit the values.yaml file and update the following sections
     - ldap : Change the example.com domain to your Active Directory domain
     - ingress: Change the host_domain value to the FQDN you want to use for your ingress URLs

6. Make sure you are in the repo directory that you cloned in step 1 and then run the following command to insall MDM
    - helm install redpoint-mdm ./redpoint-mdm

It may take a few minutes for the all the MDM services to start. Please wait about 10 minutes before testing.

### Access the MDM Web UI, Core and Authentication server endpoints
Execute the command below to get the URL endpoints 
    - kubectl get ingress 

