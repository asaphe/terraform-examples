#!/usr/bin/env bash

export TF_CREDS=$(pwd)/gcp.json
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT_ID=${1:-google-project-id}

kubectl apply -f ./yamls/namespaces.yaml

cp kubernetes_secret.terraform local_kubernetes_secret.tf
terraform plan -out=plan.tfplan -detailed-exitcode -refresh=true -target=kubernetes_secret.vault
terraform apply "plan.tfplan"