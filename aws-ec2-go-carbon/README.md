# EC2 Go-Carbon

This module sets up an EC2 instance running go-carbon and carbonapi.

**This is not** meant to be a robust permenant solution.

> After running TF with `run_provisioner=1` connect to the instance and ensure the volume is mounted before directing traffic to it

## Resources

This moudle creates the following resources

* AWS Elastic IP
* AWS Security Group
* AWS EC2 Instance
* AWS EBS Volume

## Workspaces

Example: `go-carbon_dev`

## Required Variables

* vpc_cidr - used to select the correct vpc
* availability_zone - used to select the correct subnet
* instance_type - ec2 instance type to use
* ebs_volume_size - ec2 EBS volume size to attach to the instance (`/data`)
* go-carbon-conf - set `max-cpu` and `workers` this should be based off of the instance type

```raw
vpc_cidr          = "10.50.0.0/16"
availability_zone = "euc1-az3"
instance_type     = "m4.10xlarge"
ebs_volume_size   = 3500

go-carbon-conf = {
  max-cpu = 40
  workers = 80
}
```

## Important notes

### AMI Changes

We are using an exact match for the AMI to prevent instance changes. (AMI's are updated frequently)

To be more liberal with AMI's use -- `values = ["amzn2-ami-kernel*-x86_64-gp2"]`

### Multiple instances

Each workspace represents an instance

example

```raw
  default
* go-carbon-secondary_eu2
  go-carbon-secondary_us1
  go-carbon_dev
  go-carbon_eu2
  go-carbon_stg
  go-carbon_us1
```

While not required or needed if they are the same, a file named `<ENV>_secondary.tfvars` exists in order to be clear about having multiple instances.

### EBS Volume

Currently, the volume is not destroyed. but always created.

To attach an existing volume (parameters are pre-determined) use `-var=create_ebs_volume=false` to indicate an EBS volume should not be created.

`terraform plan -out=plan.tfplan -refresh=true  -var-file="tfvars/${AWS_PROFILE}.tfvars" -var=create_ebs_volume=false`

### SSH/SCP Connection

>Requires `ssh-agent` and using `ssh-add PATH_TO_PRIVATE_KEY`

example

```shell
eval "$(ssh-agent)"
ssh-add ~/.ssh/dev_master_key
```

## Running

### First time run (New Instance and EBS)

* Planning (Create instance and EBS)

`terraform plan -out=plan.tfplan -refresh=true -var-file="tfvars/${AWS_PROFILE}.tfvars"`

> After the instance is created we need to configure it via the command below

* Planning a configuration only change (Run commands over SSH to configure the instance)

`terraform plan -var-file="tfvars/${AWS_PROFILE}.tfvars" -var=run_provisioner=1 -target=null_resource.this`

#### Post Instance Creation

The variable `run_provisioner` controls the execution the `null_resource` which templates the required configuration files.

`terraform plan -out=plan.tfplan -refresh=true -var-file="tfvars/${AWS_PROFILE}.tfvars" -var=run_provisioner=1 -target=null_resource.this`

`terraform apply plan.tfplan`

>**NOTE** if the null_resource is not executed the EBS volume won't be mounted
>
>**NOTE** the trigger is set to always execute the `null_resource`, control execution with `run_provisioner`

### New instance existing EBS

* Plan using `-var=create_ebs_volume=false` to indicate an existing EBS

`terraform plan -refresh=true -parallelism=50 -var-file="tfvars/${AWS_PROFILE}.tfvars" -var=create_ebs_volume=false`

### Modify only a specific part of the module

`terraform plan -refresh=true -parallelism=50 -var-file="tfvars/${AWS_PROFILE}.tfvars" -target=module.security-group`

### Other Terraform resources

## Carbon-Relay

To get metrics, add the private ip of this instance (available from Terraform's outputs) to the relay's destinations.

Updated in

`terraform/k8s/tfvars/${environment}.tfvars`

## Grafana

To read metrics, add the private ip of this instance as a `data source` in Grafana.

`terraform plan -out=plan.tfplan -refresh=true -var-file="tfvars/${AWS_PROFILE}.tfvars" -target=grafana_data_source.graphite`

## Route53 Record

go-carbon's route53 record is created via `terraform/k8s/go-carbon-route53-record.tf`

`terraform plan -out=plan.tfplan -refresh=true -var-file="tfvars/${AWS_PROFILE}.tfvars" -target=aws_route53_record.go-carbon`
