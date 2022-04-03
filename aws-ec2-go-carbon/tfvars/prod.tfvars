vpc_cidr                    = "10.241.64.0/18"
availability_zone           = "use1-az4"
secondary_availability_zone = "use1-az3"
instance_type               = "m4.16xlarge"

go-carbon-conf = {
  max-cpu = 64
  workers = 128
}

ebs_volume_size       = 3500
ebs_volume_iops       = 10000
ebs_volume_throughput = 250