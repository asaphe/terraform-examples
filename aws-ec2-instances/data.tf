data "aws_subnet_ids" "all" {
  vpc_id = module.vpc.vpc_id
}

data "aws_ami" "this_ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name = "name"
    values = [
      "ubuntu*19.10*",
    ]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "external" "local_ip" {
  program = ["/bin/bash", "${path.module}/icanhazip.sh"]
}