vpc_cidr          = "10.51.0.0/20"
availability_zone = "use1-az1"
instance_type     = "m4.xlarge"

go-carbon-conf = {
  max-cpu = 4
  workers = 8
}

ebs_volume_size       = 1000
ebs_volume_iops       = 5000
ebs_volume_throughput = 250