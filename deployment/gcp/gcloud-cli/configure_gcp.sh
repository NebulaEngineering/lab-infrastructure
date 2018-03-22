#!/bin/bash

#activate gcloud
gcloud auth activate-service-account gcp-config@ne-tpm-prod.iam.gserviceaccount.com --key-file=deployment/gcp/tokens/ne-tpm-prod-gcp-config.json

#Configure default project and Zone
gcloud config set project ne-tpm-prod
gcloud config set compute/zone  us-central1-a

# Create Kubernetes engine cluster
gcloud container clusters create kec-main


