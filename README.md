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
| This guide focuses on Microsoft Azure for the underlying Kubernetes infrastructure, and creates a container based MongoDB Server for the MDM system databases. This is only intended for use in a ```DEMO``` or ```DEV``` setting. However, we also show you how to customize the chart for deployment in a Production setting. Be sure to check out the ```Customize for Production``` section down below  |

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
--docker-username=$your_docker_username --docker-password=$your_docker_password --docker-email=$your_docker_email --namespace redpoint-mdm
```
4. Run the following command to install MDM
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

### Retrieve the MDM URL endpoints
The default installation includes an Nginx ingress controller that exposes the MDM UI endpoint based on the domain specified in the ingress section within the values.yaml. 
```
ingress:
  host_domain: example.com  # Replace with your custom domain
```
If you prefer to use a different Ingress controller solution, you can disable the default nginx by modifying the sections beloq
```
nginx:
  enabled: true # Change this to false
```
Run the command below to retrieve the MDM UI endpoint. This command will keep checking the ingress IP address every 10 seconds until it finds one. Once an IP address is found, it will display the IP and the corresponding ingress hostname
```sh
 NAMESPACE="redpoint-mdm"; INGRESS_IP=""; while true; do INGRESS_IP=$(kubectl get ingress --namespace $NAMESPACE -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}"); if [ -n "$INGRESS_IP" ]; then echo "IP address found: $INGRESS_IP"; kubectl get ingress --namespace $NAMESPACE; break; else echo "No IP address found, waiting for 10 seconds before checking again..."; sleep 10; fi; done
 ```
- The command returns the following URL endpoint
```sh
    - rp-mdm-ui.example.com   (This is the Web UI endpoint)
 ```  
The chart also create a TCP service of type ```LoadBalancer``` for the MDM authentication service and one for the MDM Core service. These TCP services are needed to configure the connection between MDM and Redpoint Data Management (RPDM)

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


