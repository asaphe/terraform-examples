#!/usr/bin/env bash

kubectl apply -f ./yamls/namespaces.yaml

cp kubernetes_secret.terraform local_kube_secret.tf
terraform init -backend-config=backend.hcl
terraform plan -out=plan.tfplan -detailed-exitcode -refresh=true -target=kubernetes_secret.vault
terraform apply "plan.tfplan"