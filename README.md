![RG](https://user-images.githubusercontent.com/42842390/158004336-60f07c05-7e5d-420e-87a6-22c5ac206fb6.jpg)
## Redpoint Master Data Management (MDM)
Redpoint Master Data Management (MDM) is a data stewardship system for managing the Golden Record: a single, accurate, and always up-to-date view of your most critical data. The MDM system includes a variety of capabilities for controlling your data,

MDM is packaged and distributed as docker container images that are hosted in the Redpoint Global private repository in Docker Hub.

![NEW_MDM](https://user-images.githubusercontent.com/42842390/157733806-a9c6be0a-1888-4010-8602-dc1e70fd0b22.jpg)
This documentation will show you how to Install or upgrade MDM in Kubernetes using HELM

### Table of Contents

- [Prerequisites ](#prerequisites)
- [System Requirements ](#system-requirements)
- [Install Procedure ](#install-procedure)
- [Retrieve the MDM URL Endpoints ](#retrieve-the-mdm-url-endpoints)
- [Install MDM License](#install-mdm-license)
- [Connect MDM to Redpoint Data Management](#connect-mdm-to-redpoint-data-management)
- [Troubleshooting](#troubleshooting)
- [Get MDM Support](#get-mdm-support)

### System Requirements

- MongoDB server sizing
    - 4 GB memory for data < 1 million records total: 
    - 8-16 GB memory for data 1-10 million records total
    - SSD disks for best IO perfomance
    - Size the MongoDB memory to keep working index set in memory for data > 10 million records total

- Kubernetes Cluster sizing
    - nodepool with 2-3 nodes for high availabilty
    - 8 vCPUs and 32 GB memory per node
    - 20 GB or more free disk space per node

- Kubernetes Cluster Networking
   - ```Azure CNI for cluster in Azure``` (https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni) 
   - ```VPC-Native for clusters in Google``` (https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips#:~:text=In%20GKE%2C%20clusters%20can%20be,called%20a%20routes%2Dbased%20cluster.) 
   - ```Amazon VPC CNI for clusters in AWS``` (https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)

### Prerequisites

Before you install MDM, you must:

1. Install kubectl. ( https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ )
2. Install HELM. ( https://helm.sh/docs/intro/install/ )
3. Have a Kubernetes solution available to use. ( https://kubernetes.io/docs/setup/production-environment/turnkey-solutions/ )
4. Have a MongoDB database server available to use for the MDM application Databases. ( https://docs.mongodb.com/v4.4/installation/). This can also be a managed solution like mongo Atlas.
5. Have a docker ID and provide it to Redpoint Support so they can grant you permissions to pull the MDM container images
6. Have a license key to activate MDM. Contact Redpoint support for an activation key

### Before you Install

1. Clone this repository and connect to your target Kubernetes Cluster
```sh
git clone https://github.com/RedPointGlobal/rp-mdm.git
 ```
2. Create a namespace for MDM (HELM expects a namespace named redpoint-mdm)
```sh
kubectl create namespace redpoint-mdm
 ```
3. Create the following kubernetes secrets that MDM needs
 - ```mongodb-conn-string``` | Secret that contains your mongodb connection string 
```
 kubectl create secret generic mongodb-conn-string \
--from-literal=MONGO_CONNECTION_STRING=$your_mongo_connection_string \
--namespace redpoint-mdm
```
 - ```docker-io``` | Secret that contains your docker hub credentials 
```
kubectl create secret docker-registry docker-io --docker-server='https://index.docker.io/v1/' \
--docker-username=$your_docker_username --docker-password=$your_docker_password --docker-email=$your_docker_email --namespace redpoint-mdm
```
 - ```mdm-tls``` | Secret that contains your TLS certificate files (.crt and .key)
```
kubectl create secret tls mdm-tls --cert=$your_tls_cert --key=$your_tls_key --namespace redpoint-mdm
```
4. For INGRESS and LDAP, edit the values.yaml file and update the following sections
```sh
     - ldap :   Replace the example.com domain with your Active Directory domain
     - ingress: Replace the host_domain value with the FQDN you want to use for your ingress URLs
 ```
### Install
Make sure you are in the repo directory that you cloned in step 1 and then run the following command to insall MDM
```sh
    helm install redpoint-mdm redpoint-mdm/ --values values.yaml
 ```
It may take a few minutes for the all the MDM services to start. Please wait about 10 minutes before testing.

### Retrieve the MDM URL endpoints
The chart creates an NGINX ingress controller for you and configures all the ingress rules necesssary for accessing MDM endpoints externally. It deploys a public Load Balancer by default.

If you prefer an internal load balancer, simply edit the ```nginx-redpoint-mdm``` load balancer service in ```redpoint-mdm/templates/nginx-deploy.yaml``` file and add the annotations below depending on the cloud provider
```
AZURE (AKS)
service.beta.kubernetes.io/azure-load-balancer-internal: "true"
service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "<add your subnet name>"

AWS (EKS)
service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
service.beta.kubernetes.io/aws-load-balancer-internal: "true"    
service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: 'true'    
service.beta.kubernetes.io/aws-load-balancer-type: nlb    
service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "60"

GCP (GKE)
cloud.google.com/load-balancer-type: "Internal"
```
Once that is done, upgrade the helm deployment like so ```helm upgrade redpoint-mdm redpoint-mdm/ --values values.yaml```

7. Execute the command below to get the URL endpoints 
```sh
    kubectl get ingress
 ```
- The command returns the following URL endpoints
```sh
    - rp-mdm-ui.example.com   (This is the Web UI endpoint)
    - rp-mdm-auth.example.com (This is the authentication server endpoint)
    - rp-mdm-core.example.com (This is the core service endpoint )
 ```  
### Install MDM License
Once you obtain your activation key from Redpoint Support, access the MDM web UI and provide the information below
```sh
  - Activation Key: Contact Redpoint Global support for an activation key
  - License URLs
      - For trial/demo: trial-license
      - For production: https://qlm1.net/redpointglobal/qlmlicenseserver/qlmservice.asmx
  - Public Key:       : Same as the activation key
  - Product ID:       : Prod or Trial depending on your activation key
 ```
![6f248329-95d0-4ac6-a99f-efc220e2ecb8](https://user-images.githubusercontent.com/42842390/157773834-f2fe34ed-afb5-4d5d-af22-2cc898158846.png)

After successful activation, you should see the Welcome page below 

![34ce4157-3c8c-43dc-8d00-85838237b1cb](https://user-images.githubusercontent.com/42842390/157773845-a1a972e6-f29b-4a20-a8d3-3560a9f84514.png)

### Connect MDM to Redpoint Data Management (RPDM)
To connect MDM to RPDM, you simply install the MDM Tools in RPDM as follows
 - Copy the Redpoint-provided "shaded" version of the MDM tools JAR file into the \java_plugins folder in the Redpoint Data Management installation folder. 
The filename is of the form mdm-connectors-*-shaded.jar.
 - In the Redpoint Data Management client, click the Palette menu button at the top of the tool palette and select Reset Palette.

The MDM tools will appear in the Master Data tool group.
 - Click the Repository tab and go to Settings > Tools.
 - Close and re-open any projects that were active before installing the MDM tools JAR file.
 - Click the MDM tab and enter your server and authentication credentials as shown below
```
    - Authentication Server URL: https://rp-mdm-auth.example.com/mdm
    - MDM Server URL:            https://rp-mdm-core.example.com/mdm
``` 
 ![image](https://user-images.githubusercontent.com/42842390/223878996-04c82cf7-531e-4568-9e6f-8390181628fa.png)

### Troubleshooting
If you followed this guide step by step, then things should just work out of the box. However, the most common issues we have seen our customers encounter with installation are mentioned below;

 - ```Pods are stuck in a "PENDING" state```
 
 You may notice that the Pods are stuck in a "PENDING" state. This is because the helm chart expects your kubernetes nodepool to have the following label ```application: mdm```. If you want to use a different label, update the NodeSelector section in the ```values.yaml``` file to match the labels that you have assigned to your nodepool.
```
 nodeSelector:
  key: application
  value: mdm
```
 Once this is done, the Pods will transition into the "RUNNING" state 
 
 - ```Unable to login to the UI```
 
 This is always caused by network connectivity issues when MDM pods are unable to communicate with the mongodb database server. You can confirm this by looking the container logs. Once you fix the connectivity issues, you should be able to login and also connect MDM to RPDM

### Get MDM Support 
If you believe you need additional support with installation, Contact support@redpointglobal.com for any application specific issues you may encounter. 

Generally, Kubernetes specific or other network connectivity errors are out of scope but we may be able to assist and guide where possible.
![argo-icon-small](https://user-images.githubusercontent.com/42842390/230259718-6f3eb5c5-259b-49c3-9591-50d91118e1bc.png)


