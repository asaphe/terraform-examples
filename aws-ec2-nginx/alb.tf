resource "aws_alb" "this" {
  name               = "${var.ec2_name}-alb-${random_id.suffix.hex}"
  internal           = var.load_balancer_internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [module.alb_security_group.this_security_group_id]
  subnets            = data.aws_subnet_ids.all.ids

  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.this.arn
  }
}

resource "aws_alb_target_group" "this" {
  name        = "${var.ec2_name}-tg-${random_id.suffix.hex}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    port     = 80
    protocol = "HTTP"
  }

  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "aws_alb_target_group_attachment" "this" {
  count            = var.ec2_instance_count

  target_group_arn = aws_alb_target_group.this.arn
  target_id        = element(module.ec2_instance.id, count.index)
  port             = 80
}