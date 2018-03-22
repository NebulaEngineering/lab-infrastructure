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
5. Install kubectl through gcloud:  '''gcloud components install kubectl'''
6. Authorize gcloud cli, you will need the token and the Service Account ID (you can see at GCP > IAM > Service Accounts )
   ''' gcloud auth activate-service-account <SERVICE_ACCOUNT_ID> --key-file=deployment/gcp/tokens/<TOKEN_FILE>'''
7. Configure default project.  use the project id generted at # 2
   ''' gcloud config set project [PROJECT_ID] '''
8. Configure compute zone.  Eg.: us-central1-a	
   ''' gcloud config set compute/zone [COMPUTE_ZONE] '''


### Kubernetes Engine cluster
To create a cluster, run the following command and wait...:
''' gcloud container clusters create [CLUSTER_NAME] '''

### External HTTP access
Configure Ingress controller to allow external request to reach internal services

#### Static IP Address
Create a static IP address compatible with Ingress with the name set to 'ip-web-main'.
run the following command:
''' gcloud compute addresses create ip-web-main --ip-version=IPV4 --global '''

#### Ingress controller


