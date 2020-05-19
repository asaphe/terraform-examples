locals {
  dns_record_name       = "customer-info2"
  grafana_egress_ports  = [9200, 9090, 3306, 5432]
  grafana_app_port      = 3000
  # Add plugins to the left hand side of the list (trigger workaround)
  plugin_list   = ["flant-statusmap-panel", "goshposh-metaqueries-datasource", "grafana-clock-panel", "grafana-piechart-panel", "grafana-simple-json-datasource"]

  grafana_vars = {
    name         = "grafana"
    ami          = "ami-019dd90460c6ef645"
    instanceType = "m5.large"
    sshKey       = "${var.region["short"]}-ssh-key-pair-ec2"
  }

  grafana_tags = {
    "es/domain" = "domain/example"
    service     = local.grafana_vars["name"]
  }

  grafana_ec2_tags = {
    Name    = "${var.region["short"]}-${local.grafana_vars["name"]}"
    Service = "EC2"
  }

  grafana_lb_tags = {
    Name = "${var.region["short"]}-lb-${local.grafana_vars["name"]}"
  }

  grafana_tg_tags = {
    Name = "${var.region["short"]}-tg-${local.grafana_vars["name"]}"
  }

  grafana_sg_tags = {
    Name = "${var.region["short"]}-sg-${local.grafana_vars["name"]}"
  }

  grafana_sg_lb_tags = {
    Name = "${var.region["short"]}-sg-${local.grafana_vars["name"]}-lb"
  }
}

resource "aws_security_group" "grafana_lb" {
  name        = lookup(local.grafana_sg_lb_tags, "Name", "grafana")
  description = lookup(local.grafana_sg_lb_tags, "Name", "grafana")
  vpc_id      = data.aws_vpc.prod.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.open_cidr]
    description = "HTTPS"
  }

  egress {
    from_port   = local.grafana_app_port
    to_port     = local.grafana_app_port
    protocol    = "tcp"
    cidr_blocks = [var.internal_cidr]
    description = "Application Port"
  }

  tags = merge(var.global_tags, local.grafana_tags, local.grafana_sg_lb_tags)
}

resource "aws_security_group" "grafana" {
  name        = lookup(local.grafana_sg_tags, "Name", "grafana")
  description = lookup(local.grafana_sg_tags, "Name", "grafana")
  vpc_id      = data.aws_vpc.prod.id

  ingress {
    from_port       = local.grafana_app_port
    to_port         = local.grafana_app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.grafana_lb.id]
    description     = "Application Port"
  }

  dynamic "egress" {
    for_each = local.grafana_egress_ports
    content {
      from_port = egress.value
      to_port   = egress.value
      protocol  = "tcp"
      cidr_blocks = [var.internal_cidr]
    }
  }

  tags = merge(var.global_tags, local.grafana_tags, local.grafana_sg_tags)
}

resource "aws_security_group_rule" "grafana_mysql" {
  depends_on = [aws_instance.grafana]

  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.grafana.id
  security_group_id        = data.aws_security_group.rdsCustomerInfo.id
  description              = aws_instance.grafana.tags.Name
}

resource "aws_security_group_rule" "grafana_postgresql" {
  depends_on = [aws_instance.grafana]

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.grafana.id
  security_group_id        = data.aws_security_group.rdsSmartPhish.id
  description              = aws_instance.grafana.tags.Name
}

resource "aws_security_group_rule" "grafana_postgresql_customer_info" {
  depends_on = [aws_instance.grafana]

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.grafana.id
  security_group_id        = data.aws_security_group.customer_info_ec2.id
  description              = aws_instance.grafana.tags.Name
}

resource "null_resource" "grafana_config" {
  depends_on = [aws_instance.grafana]

  triggers = {
    instance_changed = aws_instance.grafana.id
  }

  provisioner "file" {
    source      = "../files/grafana/custom.ini"
    destination = "/tmp/grafana.ini"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/grafana.ini /opt/bitnami/grafana/conf/grafana.ini",
    ]
  }

  connection {
    type                = "ssh"
    bastion_host        = data.aws_instance.bastion.private_ip
    host                = aws_instance.grafana.private_ip
    user                = "bitnami"
    bastion_user        = "ubuntu"
    bastion_private_key = file("~/.ssh/build2.pem")
    private_key         = file("~/.ssh/use1-ssh-key-pair-ec2.pem")
  }
}

# Should probably pass a script file and create a single connection instead of 1 per command
resource "null_resource" "grafana_plugins" {
  depends_on = [aws_instance.grafana]
  count      = length(local.plugin_list)

  triggers = {
    instance_changed = aws_instance.grafana.id
  }

  provisioner "remote-exec" {
    inline = [
      # for_each [?]
      "sudo grafana-cli --pluginsDir '/opt/bitnami/grafana/data/plugins/' plugins install ${local.plugin_list[count.index]}",
    ]
  }

  connection {
    type                = "ssh"
    bastion_host        = data.aws_instance.bastion.private_ip
    host                = aws_instance.grafana.private_ip
    user                = "bitnami"
    bastion_user        = "ubuntu"
    bastion_private_key = file("~/.ssh/build2.pem")
    private_key         = file("~/.ssh/use1-ssh-key-pair-ec2.pem")
  }
}

resource "null_resource" "grafana_restart" {
  triggers = {
    plugin_changes = local.plugin_list[0]
    config_changes = sha1(file("../files/grafana/custom.ini"))
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/bitnami/ctlscript.sh restart grafana",
    ]
  }

  connection {
    type                = "ssh"
    bastion_host        = data.aws_instance.bastion.private_ip
    host                = aws_instance.grafana.private_ip
    user                = "bitnami"
    bastion_user        = "ubuntu"
    bastion_private_key = file("~/.ssh/build2.pem")
    private_key         = file("~/.ssh/use1-ssh-key-pair-ec2.pem")
  }
}

resource "aws_instance" "grafana" {
  ami                                  = lookup(local.grafana_vars, "ami", "")
  tenancy                              = "default"
  instance_type                        = lookup(local.grafana_vars, "instanceType", "")
  iam_instance_profile                 = aws_iam_instance_profile.grafana.name
  disable_api_termination              = false
  associate_public_ip_address          = true
  vpc_security_group_ids               = [aws_security_group.grafana.id, aws_security_group.base.id]
  key_name                             = lookup(local.grafana_vars, "sshKey", "")
  subnet_id                            = data.aws_subnet.prod_1a.id
  instance_initiated_shutdown_behavior = "stop"

  tags = merge(var.global_tags, local.grafana_tags, local.grafana_ec2_tags)

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = "60"
  }
}

resource "aws_iam_role" "grafana" {
  name = "${local.grafana_vars["name"]}Role"
  path = "/services/${local.grafana_vars["name"]}/"
  assume_role_policy = templatefile("../templates/IAM/grafana_role_trust_policy.tpl",
    {
      self_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/services/grafana/grafanaRole"
    }
  )
}

resource "aws_iam_instance_profile" "grafana" {
  name = "${local.grafana_vars["name"]}InstanceProfile"
  role = aws_iam_role.grafana.name
}

resource "aws_iam_role_policy" "grafana" {
  name   = "${local.grafana_vars["name"]}RolePolicy"
  role   = aws_iam_role.grafana.name
  policy = file("../files/grafana/grafana_role_iam_policy.json")
}

resource "aws_route53_record" "grafana" {
  depends_on = [aws_lb.grafana]

  zone_id = data.aws_route53_zone.exampleNet.zone_id
  name    = "${local.dns_record_name}.example.net"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.grafana.dns_name]
  }

  resource "aws_lb" "grafana" {
  name                             = lookup(local.grafana_lb_tags, "Name", "grafana")
  load_balancer_type               = "application"
  ip_address_type                  = "ipv4"
  internal                         = false
  enable_cross_zone_load_balancing = false
  enable_deletion_protection       = false
  subnets                          = [data.aws_subnet.prod_1a.id, data.aws_subnet.prod_c.id]
  security_groups                  = [aws_security_group.grafana_lb.id]

  tags = merge(var.global_tags, local.grafana_tags, local.grafana_lb_tags)
}

resource "aws_lb_target_group" "grafana" {
  name                 = lookup(local.grafana_tg_tags, "Name", "grafana")
  protocol             = "HTTP"
  port                 = local.grafana_app_port
  vpc_id               = data.aws_vpc.prod.id
  target_type          = "ip"
  deregistration_delay = 30
  slow_start           = 30

  health_check {
  protocol            = "HTTP"
  path                = "/"
  port                = local.grafana_app_port
  healthy_threshold   = 5
  unhealthy_threshold = 2
  timeout             = 5
  matcher             = "200-302"
  }

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

  tags = merge(var.global_tags, local.grafana_tags, local.grafana_tg_tags)
}

resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = aws_lb_target_group.grafana.arn
  target_id        = aws_instance.grafana.private_ip
  port             = local.grafana_app_port
}

resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.grafana.arn
  protocol          = "HTTPS"
  port              = 443
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.grafana.arn

  default_action {
    target_group_arn = aws_lb_target_group.grafana.arn
    type             = "forward"
  }
}

output "grafana_instance_id" {
  description = "Grafana Instance id"
  value       = aws_instance.grafana.id
}

output "grafana_lb_arn" {
  description = "Grafana LB arn"
  value       = aws_lb.grafana.arn
}

output "grafana_r53_name" {
  description = "Grafana DNS record"
  value       = aws_route53_record.grafana.name
}