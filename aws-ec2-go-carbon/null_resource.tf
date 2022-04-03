resource "null_resource" "this" {
  depends_on = [
    module.ec2-instance
  ]

  count = var.run_provisioner

  triggers = {
    always = timestamp()
  }

  connection {
    host = aws_eip.this.private_ip
    user = "ec2-user"

    type    = "ssh"
    timeout = "5s"
  }

  provisioner "remote-exec" {
    inline = [
      "if [[ $(sudo /usr/sbin/blkid -o value -s TYPE '/dev/xvdf') != 'xfs' ]]; then sudo mkfs -t xfs /dev/xvdf > /dev/null; fi",
      "if [[ ! -d '/data' ]]; then sudo mkdir /data; fi",
      "sudo mountpoint -q /data || sudo mount /dev/xvdf /data",
      "sudo mountpoint -q /var/log/go-carbon || sudo mount /dev/xvdf /var/log/go-carbon"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "if [[ ! -d '/data/whisper' ]]; then sudo mkdir -p /data/whisper; fi",
      # so we don't have to modify the permissions of the directory itself
      "if [[ ! -f '/etc/logrotate.d/go-carbon' ]]; then sudo touch /etc/logrotate.d/go-carbon; fi",
      "if [[ ! -f '/etc/logrotate.d/carbonapi' ]]; then sudo touch /etc/logrotate.d/carbonapi; fi",
      "sudo chown ec2-user /etc/logrotate.d/{go-carbon,carbonapi}",
      "sudo chown -R ec2-user /etc/{go-carbon,carbonapi}",
      "sudo chown -R carbon:carbon /data/whisper",
      "sudo chown -R carbon:carbon /var/lib/graphite /var/log/{go-carbon,carbonapi}"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files/go-carbon.logrotate"
    destination = "/etc/logrotate.d/go-carbon"
  }

  provisioner "file" {
    source      = "${path.module}/files/carbonapi.logrotate"
    destination = "/etc/logrotate.d/carbonapi"
  }

  provisioner "file" {
    content     = data.template_file.go-carbon.rendered
    destination = "/etc/go-carbon/go-carbon.conf"
  }

  provisioner "file" {
    source      = "${path.module}/files/storage-schemas.conf"
    destination = "/etc/go-carbon/storage-schemas.conf"
  }

  provisioner "file" {
    source      = "${path.module}/files/storage-aggregation.conf"
    destination = "/etc/go-carbon/storage-aggregation.conf"
  }

  provisioner "file" {
    source      = "${path.module}/files/carbonapi.yaml"
    destination = "/etc/carbonapi/carbonapi.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/files/graphiteweb.yaml"
    destination = "/etc/carbonapi/graphiteweb.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/files/timeshift.yaml"
    destination = "/etc/carbonapi/timeshift.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown -R carbon:carbon /etc/go-carbon /etc/carbonapi",
      "sudo systemctl restart go-carbon",
      "sudo systemctl restart carbonapi"
    ]
  }
}