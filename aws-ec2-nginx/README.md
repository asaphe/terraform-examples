# AWS EC2 Nginx with Load-balancer

Developed using Terraform `0.13.5`

## Running TF

Ensure AWS configuration file exists and set your environment to the desired profile and region

```shell
export AWS_PROFILE=ocean
export AWS_REGION=us-east-2
```

Initialize Terraform

`terraform init -backend-config=backend.hcl`

Run Terraform Plan

`terraform plan -out=plan.tfplan -detailed-exitcode -refresh=true -var-file default.vars`

> Remove the defaults from `variables.tf` and create a `default.vars` file
>
> Ansible related configuration must exist on the controlling machine. recommanded usage is with the `AWS EC2 Plugin`
> Ansible `-var 'run_ansible=true'`

Run Terraform Apply

`terraform apply`

## Ansilbe

When running Ansible separately, ensure the following enviroment variables are defined:

```shell
export ANSIBLE_HOST_KEY_CHECKING=false
export ANSIBLE_REMOTE_USER=ubuntu
export ANSIBLE_PRIVATE_KEY_FILE=/tmp/ocean
```

> In addition to a proper `boto` configuration for dynamic inventory
