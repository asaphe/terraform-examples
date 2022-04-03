#!/bin/bash

sysctl -w vm.dirty_ratio=80
sysctl -w vm.dirty_background_ratio=50
sysctl -w vm.dirty_expire_centisecs=$(( 10*60*100 ))

yum update -y
yum install xfsprogs
yum install git-core -y

mkdir -p /var/lib/graphite/{dump,tagging} /var/log/{go-carbon,carbonapi} /etc/carbonapi
chown -R carbon:carbon /var/lib/graphite /var/log/{go-carbon,carbonapi}

export AWS_REGION=us-east-1

aws s3 cp s3://provision/go-carbon/carbonapi-0.15.4~1-1.x86_64.rpm /tmp
aws s3 cp s3://provision/go-carbon/go-carbon-0.15.6-1.x86_64.rpm /tmp

yum install /tmp/go-carbon-0.15.6-1.x86_64.rpm -y
yum install /tmp/carbonapi-0.15.4~1-1.x86_64.rpm -y
yum install amazon-cloudwatch-agent -y

systemctl enable go-carbon
systemctl enable carbonapi