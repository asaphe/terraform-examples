# GCP GKE with Hashicorp Vault

This example will setup a GKE cluster and using the files under `./scripts` will help you deploy and configure Hashicorp Vault on top of it.

Requires:

- A Service account to run terraform
- GCP Credentials ENV variables
  `export GOOGLE_PROJECT_ID=my-project`
  `export TF_CREDS=/path/to/gcp/credentials/file`
  `export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}`
- Hashicorp Vault Helm chart

```shell
terraform plan -out=plan.tfplan -detailed-exitcode -refresh=true \
-var project_id='gcp_project_id' -var prefix='prefix' \
-var name='name' -var istio=false \
-var kms_key_ring='vault-auto-unseal'
```

1. Terraform plan & Apply
2. `./scripts/gcld.sh`
3. `./scripts/kube.sh`
4. `./scripts/helm.sh`
5. `./scripts/vault.sh`
