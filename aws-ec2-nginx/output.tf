output "ec2_public_ip" {
  description = "Public IP address assigned to the first instance"
  value       = module.ec2_instance.*.public_ip
}

output "ec2_user" {
  description = "User to access the EC2 instance with"
  value       = var.ec2_user
}

output "alb_dns" {
  description = "Application load-balancer dns name"
  value       = aws_alb.this.dns_name
}

output "private_key_pem" {
  description = "The private key (PEM) of the generated keypair"
  value       = tls_private_key.this.private_key_pem
}

output "private_key_pem_location" {
  description = "The private key (PEM) location of the generated keypair"
  value       = local.private_key_path
}