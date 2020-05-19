output "public_ip" {
  description = "Public IP address assigned to the first instance"
  value       = module.ec2.public_ip[0]
}

output "private_key_pem" {
  description = "The private key (PEM) of the generated keypair"
  value       = tls_private_key.this.private_key_pem
}

output "private_key_pem_location" {
  description = "The private key (PEM) location of the generated keypair"
  value       = local.private_key_path
}