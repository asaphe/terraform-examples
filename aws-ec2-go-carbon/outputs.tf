output "region" {
  value = data.aws_availability_zone.this.region
}

output "ami_name" {
  value = data.aws_ami.this.name
}

output "ami_id" {
  value = data.aws_ami.this.id
}

output "instance_eip_private" {
  value = aws_eip.this.private_ip
}

output "instance_eip_public" {
  value = aws_eip.this.public_ip
}

output "aws_key_pair_name" {
  value = data.aws_key_pair.this.key_name
}

output "aws_key_pair_arn" {
  value = data.aws_key_pair.this.arn
}

output "route53_zone" {
  value = data.aws_route53_zone.this.name
}

output "availability_zone" {
  value = data.aws_availability_zone.this.name
}

output "vpc_id" {
  value = data.aws_vpc.this.id
}

output "subnet_id" {
  value = data.aws_subnet.this.id
}

output "instance_profile_arn" {
  value = aws_iam_role.this.arn
}

output "instance_profile_name" {
  value = aws_iam_role.this.name
}

output "reminder" {
  value = "Remember to re-run Terraform with -var=run_provisioner=1. Requires ssh-agent and ssh-add <privatekeyfile> "
}