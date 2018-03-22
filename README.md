# Nebula Engineering Micro-Services platform deployment
Compilation of steps and recomendations to create a Micro-Services platform compatible with NebulaE guidelines
This guide asummes you have cloned this repository to your local file system.

## Google Cloud Platform
Instructions to configure Google Cloud Platform.

Requirements
1. Create a GCP account at https://console.cloud.google.com/
2. Create a new project and be aware of the generated project-id
3. Generate a JSON account token:
  1. Navigate to IAM & Admin > Service Account > Create
  2. Set a name for the service account Eg.: gcp-config
  3. Set role to 'Project > Owner'
  4. Check 'Furnish a new private key' 
  5. Select 'Key Type: JSON'
  6. Create and store the downloaded token.  If the token was not generated, you can go to the service account list, open the menu for the newly created service account and download it again.
  7. Change the file name of the token to: '<PROJECT_NAME>-<SERVICE_ACCCOUNT_NAME>.json'.  Eg: myproject-gcp-config.json
  8. Move the Service Account file to <GIT_ROOT>/deployment/gcp/tokens/
4. Install Google Cloud SDK https://cloud.google.com/sdk/
5. Install kubectl through gcloud:  
   ```gcloud components install kubectl```
6. Authorize gcloud cli, you will need the token and the Service Account ID (you can see at GCP > IAM > Service Accounts )
   ``` gcloud auth activate-service-account <SERVICE_ACCOUNT_ID> --key-file=deployment/gcp/tokens/<TOKEN_FILE>```
7. Configure default project.  use the project id generted at # 2
   ``` gcloud config set project [PROJECT_ID] ```
8. Configure compute zone.  Eg.: us-central1-a	
   ``` gcloud config set compute/zone [COMPUTE_ZONE] ```


### Kubernetes Engine cluster
To create a cluster, run the following command and wait...:
``` gcloud container clusters create [CLUSTER_NAME] ```

### Deploy Kubernetes
To deploy an application into kubernetes you can use Declarative Management using configuration files.
more: https://kubernetes.io/docs/concepts/overview/object-management-kubectl/declarative-config/

You can find a sample deployment config [here](deployment/gcp/kubernetes_configs/sample-apache-web.yml)

to deploy the sample web run the following command:
```kubectl apply -f deployment/gcp/kubernetes_configs/sample-apache-web.yml```


### External HTTP access
Configure Ingress controller to allow external request to reach internal services

#### Static IP Address
Create a static IP address compatible with Ingress with the name set to 'ip-web-main'.
run the following command:
``` gcloud compute addresses create ip-web-main --ip-version=IPV4 --global ```

#### Ingress controller
Ingress can provide load balancing, SSL termination and name-based virtual hosting.
more at: https://kubernetes.io/docs/concepts/services-networking/ingress/ 

Now, this controller will be the entry point, and depending on the URI it is going to route the request to an inner services.
More advanced topics:
* Session Persistence: https://github.com/nginxinc/kubernetes-ingress/tree/master/examples/session-persistence
* WebSocket support: https://github.com/nginxinc/kubernetes-ingress/tree/master/examples/websocket
* Load Balancing: https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer

Declarative config file sample that redirects http://STATIC_IP/ to the sample frontend application
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-web-main
  annotations:
    # Use a static ip
    kubernetes.io/ingress.global-static-ip-name: ip-web-main
spec:
  backend:
    serviceName: frontend-sample
    servicePort: 80
```

to deploy Ingress run the following command:

```kubectl apply -f CONFIG_FILE.yml```



