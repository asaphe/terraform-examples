resource "aws_eip" "this" {
  vpc  = true
  tags = local.tags
}

resource "aws_eip_association" "this" {
  instance_id   = module.ec2-instance.id
  allocation_id = aws_eip.this.id
}