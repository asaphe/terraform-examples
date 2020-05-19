resource "aws_key_pair" "this" {
  key_name   = "${var.prefix}-${var.project}"
  public_key = var.public_key
}


module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.4"

  name        = "${var.prefix}-${var.project}"
  description = "Security group for ${var.project}"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["${data.external.local_ip.result["IP"]}"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_eip" "this" {
  vpc      = true
  instance = module.ec2.id[0]
}

module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 2.7"

  create_role = true

  role_name         = "${var.prefix}-${var.project}-kubeadm"
  role_requires_mfa = false

  trusted_role_services = ["ec2.amazonaws.com"]

  custom_role_policy_arns = [
    module.iam_policy_masters.arn,
    module.iam_policy_nodes.arn,
  ]
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.13"

  instance_count = 1

  name                        = "${var.prefix}-${var.project}"
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  iam_instance_profile        = module.iam_role.this_iam_instance_profile_arn
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 20
    },
  ]

  tags = merge(
    var.tags,
    {
      Project = "${var.project}",
      Owner   = "${var.prefix}-${var.project}",
    }
  )
}
