#!/bin/bash

#activate gcloud
gcloud auth activate-service-account $GCP_SERVICE_ACCOUNT_ID --key-file=deployment/gcp/tokens/ne-tpm-prod-gcp-config.json

#Configure default project and Zone
gcloud config set project ne-tpm-prod
gcloud config set compute/zone  us-central1-a

# Create Kubernetes engine cluster and link kubectl
gcloud container clusters create kec-main
gcloud container clusters get-credentials kec-main

# Deploy secrets
kubectl create -f deployment/gcp/secrets/secret-keycloak.yml


# Deploy ingress 
# KEYCLOAK, EMI AND API_GATEWAY MUST BE DEPLOYED!!!
kubectl apply -f deployment/gcp/kubernetes_configs/ingress-web-main.yml

