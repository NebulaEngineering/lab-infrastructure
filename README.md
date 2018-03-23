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

#### Enable kubectl
In order to link kubectl to the Kubernetes cluster, run the following command:

```gcloud container clusters get-credentials [CLUSTER_NAME]```


#### Deploy Kubernetes
To deploy an application into kubernetes you can use Declarative Management using configuration files.
more: https://kubernetes.io/docs/concepts/overview/object-management-kubectl/declarative-config/

You can find a sample deployment config [here](deployment/gcp/kubernetes_configs/sample-apache-web.yml)

to deploy the sample web run the following command:

```kubectl apply -f deployment/gcp/kubernetes_configs/sample-apache-web.yml```

#### Environment variables & Secrets
Secrets are intended to hold sensitive information, such as passwords, OAuth tokens, and ssh keys. Putting this information in a secret is safer and more flexible than putting it verbatim in a pod definition or in a docker image.  They are pretty handy as Environmental variables for each Microservices, Eg. Database credentials, Kakfa address, etc.

More info [here](https://kubernetes.io/docs/concepts/configuration/secret/) and [here](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/)

This docoment exposes only two ways of storing secrets:
1. using 'kubectl create secret generic' and pass key/val arguments
   
   ``` $ kubectl create secret generic [SECRET_NAME] --from-literal=[KEY]=[VAL] --from-literal=[KEY_2]=[VAL_2] ```
2. using 'kubectl create -f' and pass a YAML file.
   
   ``` $ kubectl create -f secret.yaml ```

Here is a configuration file you can use to create a Secret that holds your username and password:
```
apiVersion: v1
kind: Secret
metadata:
  name: test-secret
data:
  username: bXktYXBw
  password: Mzk1MjgkdmRnN0pi
```

Please note that all values are enconded in BASE64

To query your secrets you can run the following command:

``` kubectl get secret [SECRET_NAME] ```

The stored secrets can be used now on other Deployments YAML files like this:
```
...
spec:      
      containers:
      - image: mysql
        name: mysql
        env:                
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: [SECRET_NAME]
              key: [PROPERTY_KEY]
...
```

Secrets can be also accessed through a Volume

```
apiVersion: v1
kind: Pod
metadata:
  name: secret-test-pod
spec:
  containers:
    - name: test-container
      image: nginx
      volumeMounts:
          # name must match the volume name below
          - name: secret-volume
            mountPath: /etc/secret-volume
  # The secret data is exposed to Containers in the Pod through a Volume.
  volumes:
    - name: secret-volume
      secret:
        secretName: [SECRET_NAME]

``` 

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

```kubectl apply -f [CONFIG_FILE]```

