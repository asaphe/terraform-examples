module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.4.0"

  depends_on = [aws_iam_role.this]

  name          = local.name
  ami           = data.aws_ami.this.id
  key_name      = data.aws_key_pair.this.key_name
  instance_type = var.instance_type
  monitoring    = var.instance_monitoring

  iam_instance_profile = local.iam_instance_profile

  vpc_security_group_ids = [module.security-group.id]
  subnet_id              = data.aws_subnet.this.id

  associate_public_ip_address = var.associate_public_ip_address

  enable_volume_tags = var.enable_volume_tags
  volume_tags        = local.tags

  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_type           = "gp3"
      volume_size           = 16
    }
  ]

  ebs_block_device = var.create_ebs_volume ? local.ebs_block_device : []

  user_data = file("${path.module}/files/userdata.sh")

  tags = local.tags
}