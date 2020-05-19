locals {
  aws_key_pair_name = "${var.prefix}-${var.project}-${var.key_name}"
  private_key_path  = "${var.key_location}/${var.key_name}"
  tags = {
    Terraform = "True",
    Project = "${var.project}",
    Owner   = "${var.prefix}-${var.project}"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>2.33.0"

  name = "${var.prefix}-${var.project}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = ["${cidrsubnet(var.vpc_cidr, 3, 2)}", "${cidrsubnet(var.vpc_cidr, 3, 3)}", "${cidrsubnet(var.vpc_cidr, 3, 4)}"]
  public_subnets  = ["${cidrsubnet(var.vpc_cidr, 3, 5)}", "${cidrsubnet(var.vpc_cidr, 3, 6)}", "${cidrsubnet(var.vpc_cidr, 3, 7)}"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = true

  tags = merge(
    local.tags,
    var.user_tags
  )
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.4"

  name        = "${var.prefix}-${var.project}"
  description = "Security group for ${var.project}"
  vpc_id      = module.vpc.default_vpc_id

  ingress_cidr_blocks = ["${data.external.local_ip.result["IP"]}", var.vpc_cidr]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]

  tags = merge(
    local.tags,
    var.user_tags
  )
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.13.0"

  instance_count = var.instance_count

  name                        = "${var.prefix}-${var.project}"
  ami                         = data.aws_ami.this_ami.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  associate_public_ip_address = var.public_ip

  user_data = "${file("${path.module}/userdata.sh")}"

  ebs_block_device = [
    {
      device_name           = "/dev/sda"
      volume_size           = var.root_ebs_volume_size
      volume_type           = var.root_ebs_volume_type
      delete_on_termination = true
    }
  ]

  tags = merge(
    local.tags,
    var.user_tags
  )
}

resource "aws_eip" "this" {
  vpc      = true
  instance = module.ec2.id[0]
}

resource "aws_volume_attachment" "this_ec2" {
  count = var.instance_count

  device_name = "/dev/xvda"
  volume_id   = aws_ebs_volume.this[count.index].id
  instance_id = module.ec2.id[count.index]
}

resource "aws_ebs_volume" "this" {
  count = var.instance_count

  availability_zone = module.ec2.availability_zone[count.index]
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type

  tags = merge(
    local.tags,
    var.user_tags
  )
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "aws_key_pair" "this" {
  key_name   = local.aws_key_pair_name
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = local.private_key_path
  file_permission = "0600"
}