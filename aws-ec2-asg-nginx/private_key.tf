resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "aws_key_pair" "keypair" {
  key_name   = var.key_name
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = local.private_key_path
  file_permission = "0700"
}