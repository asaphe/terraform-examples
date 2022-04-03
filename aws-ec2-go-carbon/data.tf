data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220310.0-x86_64-gp2"]
  }
}

data "aws_route53_zone" "this" {
  name         = "${local.environment == "eu2" ? "prod-eu-2" : local.environment}.internal"
  private_zone = true
}

data "aws_availability_zone" "this" {
  zone_id = local.availability_zone
  state   = "available"
}

data "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
}

data "aws_subnet" "this" {
  vpc_id            = data.aws_vpc.this.id
  availability_zone = data.aws_availability_zone.this.name

  tags = {
    Name = "internal-${local.environment}"
  }
}

data "aws_key_pair" "this" {
  key_name = module.common_config.aws_key_pair.current
}

data "template_file" "go-carbon" {
  template = file("${path.module}/files/go-carbon.conf.tmpl")

  vars = {
    max-cpu = var.go-carbon-conf["max-cpu"]
    workers = var.go-carbon-conf["workers"]
  }
}

data "aws_security_group" "k8s-worker" {
  name = "go-carbon-${local.environment}"
}

data "aws_security_group" "go-graphite-ebs-instance" {
  name = "go-graphite-ebs-instance-${local.environment}"
}

data "aws_ebs_volume" "existing" {
  count = var.create_ebs_volume ? 0 : 1

  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "size"
    values = ["${var.ebs_volume_size}"]
  }

  filter {
    name   = "tag:Name"
    values = ["${local.name}"]
  }
}