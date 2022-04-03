locals {
  workspace_split      = split("_", terraform.workspace)
  environment          = var.environment == null ? element(local.workspace_split, length(local.workspace_split) - 1) : var.environment
  name                 = "${local.workspace_split[0]}-${local.environment}"
  availability_zone    = length(regexall(".*[secondary].*", "${local.workspace_split[0]}")) > 0 ? var.availability_zone : var.secondary_availability_zone
  username             = var.username == null ? "Created by Terraform" : var.username
  iam_instance_profile = var.iam_instance_profile != null ? var.iam_instance_profile : aws_iam_instance_profile.this.name
  tags                 = merge(var.common_tags, local._tags, var.tags)

  _tags = {
    "Username" = local.username
    "Name"     = local.name
  }

  ebs_block_device = [
    {
      delete_on_termination = var.ebs_volume_delete_on_termination
      encrypted             = true
      device_name           = "/dev/xvdf"
      volume_type           = "gp3"
      volume_size           = var.ebs_volume_size
      iops                  = var.ebs_volume_iops
      throughput            = var.ebs_volume_throughput
    }
  ]
}