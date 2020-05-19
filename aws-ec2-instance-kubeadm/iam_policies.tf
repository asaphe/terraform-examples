module "iam_policy_masters" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 2.7"

  name        = "${var.prefix}-${var.project}-kubeadm-masters"
  path        = "/"
  description = "IAM Policy for Kubernetes masters"

  policy = "${file("${path.module}/jsons/masters.json")}"
}

module "iam_policy_nodes" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 2.7"

  name        = "${var.prefix}-${var.project}-kubeadm-nodes"
  path        = "/"
  description = "IAM Policy for Kubernetes nodes"

  policy = "${file("${path.module}/jsons/nodes.json")}"
}