resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~>3.8.0"

  name    = "nginx-asg"
  lc_name = "nginx-lc"

  image_id         = data.aws_ami.ubuntu.id
  instance_type    = var.ec2_instance_type
  security_groups  = [module.ec2_security_group.this_security_group_id]
  key_name         = var.key_name

  root_block_device = [
    {
      volume_size = "10"
      volume_type = "gp2"
    },
  ]

  vpc_zone_identifier       = tolist(data.aws_subnet_ids.all.ids)
  health_check_type         = "EC2"
  min_size                  = 2
  max_size                  = 2
  desired_capacity          = 2
  wait_for_capacity_timeout = 0

  tags = [{
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }]
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = module.autoscaling.this_autoscaling_group_id
  alb_target_group_arn   = aws_alb_target_group.this.arn
}