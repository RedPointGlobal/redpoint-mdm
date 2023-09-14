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
   - [MDM Endpoints ](#mdm-endpoints)
   - [MDM Activation](#mdm-activation)
   - [Connect MDM to Redpoint Data Management](#connect-mdm-to-redpoint-data-management)
- [Customize for Production ](#customize-for-production)
   - [MongoDB ](#mongodb)
   - [Ingress ](#ingress)
- [Customize for Cloud Provider ](#customize-for-cloud-provider)
- [Migrate MDM from Docker to Kubernetes ](#migrate-mdm-from-docker-to-kubernetes)
- [Troubleshooting](#troubleshooting)
- [Upgrading MDM](#upgrading-mdm)
- [MDM Support](#mdm-support)

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

### Prerequisites
Before you install MDM, you must:

1. Install kubectl. ( https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ )
2. Install HELM. ( https://helm.sh/docs/intro/install/ )
3. Have a Kubernetes solution available to use. ( https://kubernetes.io/docs/setup/production-environment/turnkey-solutions/ )
4. Have a MongoDB database server available to use for the MDM application Databases. ( https://docs.mongodb.com/v4.4/installation/). This can also be a managed solution like mongo Atlas.
5. Have a docker ID and provide it to Redpoint Support so they can grant you permissions to pull the MDM container images
6. Have a license key to activate MDM. Contact Redpoint support for an activation key

| **NOTE:** Before you Begin!           |
|---------------------------------------|
| This guide focuses on Microsoft Azure for the underlying Kubernetes infrastructure, and creates a container based MongoDB Server for the MDM system databases. This is only intended for use in a ```DEMO``` or ```DEV``` setting. For Production specific settings, refer to the ```Customize for Production``` section down below. |

### Install Procedure
1. Clone this repository and connect to your target Kubernetes Cluster
```sh
git clone https://github.com/RedPointGlobal/rp-mdm.git
 ```
2. Make sure you are inside the redpoint-mdm directory
```
cd redpoint-mdm
```
3. Create a kubernetes secret that contains your docker hub credentials 
```
kubectl create secret docker-registry docker-io --docker-server='https://index.docker.io/v1/' \
--docker-username=$your_docker_username --docker-password=$your_docker_password \
--namespace redpoint-mdm
```
4. Create a kubernetes secret that contains the certificate files for your custom domain. This is used by the default nginx ingress controller to terminate TLS for your custom domain. If this secret is not created, you will get a ```502 Bad Gateway``` when you try to access the MDM Web UI
```
kubectl create secret tls mdm-tls --cert=$your_tls_cert --key=$your_tls_key --namespace redpoint-mdm
```
If you prefer to use a different Ingress solution, disable the default ingress as described here [MDM Ingress ](#mdm-ingress) 

5. Run the following command to install MDM
```
kubectl config set-context --current --namespace=redpoint-mdm \
&& helm install redpoint-mdm redpoint-mdm/ --values values.yaml --create-namespace
 ```
If everything goes well, You should see the output below.
```
NAME: redpoint-mdm
LAST DEPLOYED: Sat Apr  8 20:13:56 2023
NAMESPACE: redpoint-mdm
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
********************************* SUCCESS! ************************************************************
MDM has successfully been installed in your cluster.
  - It may take a few minutes for the all the MDM services to start. Please wait about 10 minutes.
```
### MDM Endpoints
The default installation exposes the MDM Web UI using an Nginx ingress controller that is deployed by default. To retrieve the Web UI endpoint, run the command below.
```
kubectl get ingress --namespace redpoint-mdm
 ```
- The command returns the following URL endpoint
```sh
rp-mdm-ui.example.com
 ```  
In addition to the Web UI, the default installation exposed two ```LoadBalancer``` services required to expose MDM Core and Authentication services over ```TCP```. These will be required when configuring MDM to interact with Redpoint Data Management (RPDM)

You can retrieve these two services using the command below
```
kubectl get service rp-mdm-core-tcp  # IP address of the MDM Core service
kubectl get service rp-mdm-auth-tcp  # IP address of the MDM Authentication service
```
### MDM Activation
Once you have MDM installed and obtained your activation key from Redpoint Support, you can proceed to activate MDM. Login to the Web UI using the default username```system``` and password ```system```. Then input the activation license as shown below.
```sh
  Demo license url:        trial-license
  Production license url:  https://qlm1.net/redpointglobal/qlmlicenseserver/qlmservice.asmx
  Public Key:              Same as the activation key
  Product ID:              Prod or Trial depending on your activation key
 ```
![6f248329-95d0-4ac6-a99f-efc220e2ecb8](https://user-images.githubusercontent.com/42842390/157773834-f2fe34ed-afb5-4d5d-af22-2cc898158846.png)
After successful activation, you should see the Welcome page below 
![34ce4157-3c8c-43dc-8d00-85838237b1cb](https://user-images.githubusercontent.com/42842390/157773845-a1a972e6-f29b-4a20-a8d3-3560a9f84514.png)
### Connect MDM to Redpoint Data Management (RPDM)
To connect MDM to RPDM, you need the IP address of the Core and Authentication service. 

1. Retrieve the MDM Core and MDM Authentication service IP addresses
```
kubectl get service rp-mdm-core-tcp  # IP address of the MDM Core service
kubectl get service rp-mdm-auth-tcp  # IP address of the MDM Authentication service
```
2. Download the MDM tools JAR from a download url provided by Redpoint Support
3. Place the JAR file into the ```\java_plugins``` folder in the Redpoint Data Management installation folder. The filename is of the form ```mdm-connectors-*-shaded.jar```.
4. In the Redpoint Data Management client, click the Palette menu button at the top of the tool palette and select ```Reset Palette```. The tools will appear in the Master Data tool group.

 - Click the Repository tab and go to ```Settings > Tools```.
 - Close and re-open any projects that were active before installing the MDM tools JAR file.
 - Click the MDM tab and enter your server and authentication credentials as shown below
```
Authentication Server URL: http://<IP address of MDM Auth service>:9901/mdm
MDM Server URL:            http://<IP address of MDM Core service>:9902/mdm

Example:
Authentication Server URL: http://10.60.0.20:9901/mdm
MDM Server URL:            http://10.60.0.30:9902/mdm
``` 
 ![image](https://user-images.githubusercontent.com/42842390/223878996-04c82cf7-531e-4568-9e6f-8390181628fa.png)
### Customize for Production
  ### MongoDB
In a Production setting, you will need to use a production-grade database server.
- Disable the default Mongodb creation in the ```values.yaml``` file
```
mongodb:
  enabled: true # Change this to false
```
Provide a the connection sting for your production server.
```
  mongodb:
   connection_string: mongodb://<root user>:<password>@<server name>:27017/admin?authSource=admin
```
  ### Ingress
The default installation includes an Nginx ingress controller that exposes the MDM UI endpoint based on the domain specified in the ingress section within the values.yaml. If you prefer to use a different Ingress controller solution, you can disable the default nginx by modifying the sections below
```
nginx:
  enabled: true             # Change this to false 
  host_domain: example.com  # Replace with your custom domain
```
### Customize for Cloud Provider
If you are deploying in Amazon or Google Cloud, make the following adjustments in the ```values.yaml``` file. This ensures that the cloud specific annotations and configurations are set for the MDM Ingress and Service Objects.
```
global:
  cloudProvider: azure # or google or amazon 
```
### Migrate MDM from Docker to Kubernetes
While you can still install and operate MDM on virtual machines using docker, Redpoint does not recommend this approach. Redpoint recommends you migrate your MDM production workloads to Kubernetes. Redpoint does not support MDM production workloads installed on docker.

Redpoint recommends migrating your MDM workloads from Docker virtual machines to Kubernetes using a blue/green approach to ensure a smooth transition with minimal downtime. Here are the general steps you can follow:

1. Set up a Kubernetes cluster: As described in the ```Prerequisites``` section above
2. Set up a new MongoDB server: As described in the ```Prerequisites``` section above
3. Deploy MDM to the Kubernetes cluster as described in the ```Install Procedure``` section above
4. Copy all Mongo collections from the ```rpmdm_system``` database to the ```rpmdm_system``` on the new MongoDB server
5. Copy all User created MDM databases from the old MongoDB server to the new MongoDB server. You can use a tool like ```Studio 3T``` to do the copy operations. Tool can be downloaded from here https://studio3t.com/
6. Test the new MDM version: Once the new version is deployed, thoroughly test it to ensure it's functioning correctly and meets your expectations. 
7. Switch traffic to the new version: If the new version passes all tests and is ready for production
8. Cleanup: Once you're confident that the new version is running smoothly, you can clean up the old version from the Docker virtual machines and decommission them.

### Troubleshooting
If you followed this guide step by step, then things should just work out of the box. However, the most common issues we have seen our customers encounter with installation are mentioned below;
 
```Unable to login to the Web UI```
 
 This is always caused by network connectivity issues. If MDM is unable to communicate with the mongodb database server, you wont be able to login. You can confirm this by looking at the container logs for the ```rp-mdm-core``` and ```rp-mdm-auth``` pods. Once you fix the connectivity issues, you should be able to login and also connect MDM to RPDM

 ```Nginx 502 Bad Gateway when accessing the Web UI```

The default installation requires that you create a kubernetes ```tls``` secret for you certificate data. The secret must be named ```mdm-tls```. If this secret is missing, Nginx wont know how to route the requests for the Web UI. Creating this secret with the relevant certficate data should resolve this issue

### Upgrading MDM
If you installed MDM using this helm chart, upgrading to a new version can be accomplished in just a few steps as described below
- Pull the latest chart manifests
 ```git pull to get the latest chart manifests
```
- Upgrade your installation
```
helm upgrade redpoint-mdm redpoint-mdm/ --values values.yaml
```
### MDM Support 
If you believe you need additional support with installation, Contact support@redpointglobal.com for any application specific issues you may encounter. Kubernetes specific or other network connectivity errors are out of scope



