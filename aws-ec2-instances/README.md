# AWS EC2 Kafka

## Credentials [Required]

Credentials are passed using environment variables.

```bash
export AWS_PROFILE=my-profile
export AWS_REGION=eu-west-1
```

## State

If you want to use AWS S3 for Terraform state edit the `backend.hcl` file to suit your needs.

> **An existing S3 Bucket is required**

```bash
terraform init -backend-config=backend.hcl
terraform plan -out=plan.tfplan -detailed-exitcode -refresh=true
terraform apply "plan.tfplan"
```

## Variables

Variables can be set using `terraform.tfvars` and using an override file as needed or passed via the CLI.

```bash
terraform plan -out=plan.tfplan -detailed-exitcode -refresh=true \
                                                   -var tags="{\"Owner\":\"Example\",\"Project\":\"Test\"}" \
                                                   -var region="${AWS_REGION}"
```

## SSH to the created instance

Since `terraform` is responsible for creating a new SSH key pair, perform the following
steps to access the instance:

```bash
ssh -i $(terraform output private_key_pem_location) ${USERNAME}@$(terraform output public_ip)
```
