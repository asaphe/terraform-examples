resource "aws_volume_attachment" "this" {
  depends_on = [module.ec2-instance]

  count = var.create_ebs_volume ? 0 : 1

  device_name = "/dev/xvdf"
  volume_id   = data.aws_ebs_volume.existing[0].volume_id
  instance_id = module.ec2-instance.id
}