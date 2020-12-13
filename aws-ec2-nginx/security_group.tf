module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.13.0"

  name        = "${var.ec2_name}-${random_id.suffix.hex}"
  description = "ALB Security Group"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = [data.external.local_ip.result["IP"], data.aws_vpc.default.cidr_block]
  ingress_rules       = ["ssh-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

module "alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.13.0"

  name        = "${var.ec2_name}-${random_id.suffix.hex}"
  description = "ALB Security Group"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = [data.external.local_ip.result["IP"]]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}