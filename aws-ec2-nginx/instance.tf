module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~>2.16.0"

  name                   = var.ec2_name
  instance_count         = var.ec2_instance_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [module.ec2_security_group.this_security_group_id]
  subnet_id              = tolist(data.aws_subnet_ids.all.ids)[0]

  associate_public_ip_address = var.ec2_assign_public_ip

  ebs_block_device = [
    {
      device_name = "/dev/sdb"
      volume_size = 10
      volume_type = "gp2"
      delete_on_termination = true
    }
  ]

  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "null_resource" "ansible_playbook" {
  count      = var.run_ansible == "true" ? 1 : 0

  connection {
    type        = "ssh"
    private_key = tls_private_key.this.private_key_pem
    user        = var.ec2_user
    host        = module.ec2_instance.public_ip[0]
  }

  provisioner "local-exec" {
    working_dir = "./ansible"
    command     = "ansible-playbook nginx.yml -i ${module.ec2_instance.public_ip[0]}"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = var.ansible_host_key_checking
      ANSIBLE_REMOTE_USER       = var.ec2_user
      ANSIBLE_PRIVATE_KEY_FILE  = local.private_key_path
    }
  }
}