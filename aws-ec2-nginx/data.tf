data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "ubuntu" {
  most_recent  = true
  owners       = ["099720109477"]

  filter {
    name = "name"
    values = [
      "ubuntu*bionic*18.04*",
    ]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
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