module "security-group" {
  source = "../shared-modules/aws/security_group"

  name                        = split("_", terraform.workspace)[0]
  environment                 = local.environment
  username                    = local.username
  component_name              = local.name

  revoke_rules_on_delete = true
  allow_all_egress       = false

  vpc_id = data.aws_vpc.this.id

  rules = {
    "Allow all ICMPv4 traffic from self" = {
      protocol  = "icmp"
      from_port = -1
      to_port   = -1
      self      = true
    }

    "Allow all TCP traffic from self" = {
      protocol  = "tcp"
      from_port = 0
      to_port   = 65535
      self      = true
    }

    "Allow all UDP traffic from self" = {
      protocol  = "udp"
      from_port = 0
      to_port   = 65535
      self      = true
    }

    "Allow egress traffic to all" = {
      type        = "egress"
      protocol    = "all"
      from_port   = -1
      to_port     = -1
      cidr_blocks = ["0.0.0.0/0"]
    }

    "Allow carbon from kubernetes workers" = {
      protocol                 = "tcp"
      from_port                = 2003
      to_port                  = 2003
      source_security_group_id = data.aws_security_group.k8s-worker.id
    }

    "Allow carbonapi from ec2 go-graphite" = {
      protocol                 = "tcp"
      from_port                = 8080
      to_port                  = 8080
      source_security_group_id = data.aws_security_group.go-graphite-ebs-instance.id
    }
    "Allow SSH" = {
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = var.cidr_blocks
    }

    "Allow carbon" = {
      protocol    = "tcp"
      from_port   = 2003
      to_port     = 2003
      cidr_blocks = var.cidr_blocks
    }

    "Allow carbon" = {
      protocol    = "tcp"
      from_port   = 2004
      to_port     = 2004
      cidr_blocks = var.cidr_blocks
    }

    "Allow carbonlink" = {
      protocol    = "tcp"
      from_port   = 7002
      to_port     = 7002
      cidr_blocks = var.cidr_blocks
    }

    "Allow carbon-admin" = {
      protocol    = "tcp"
      from_port   = 8082
      to_port     = 8082
      cidr_blocks = var.cidr_blocks
    }
  }
}