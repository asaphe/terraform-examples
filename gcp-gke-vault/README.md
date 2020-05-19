# GCP GKE with Hashicorp Vault

This example will setup a GKE cluster and using the files under `./scripts` will help you deploy and configure Hashicorp Vault on top of it.

Requires:

- A Service account to run terraform
- GCP Credentials ENV variables
  `export GOOGLE_PROJECT_ID=my-project`
  `export TF_CREDS=/path/to/gcp/credentials/file`
  `export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}`
- Hashicorp Vault Helm chart
