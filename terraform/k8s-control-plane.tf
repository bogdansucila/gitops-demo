resource "aws_eks_cluster" "primary" {
  name     = var.cluster_name
  role_arn = aws_iam_role.control_plane.arn
  version  = var.k8s_version

  vpc_config {
    security_group_ids = [aws_security_group.worker.id]
    subnet_ids         = aws_subnet.worker[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.service,
  ]
}

resource "aws_iam_role" "control_plane" {
  name               = "${title(var.cluster_name)}-Control-Plane"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.control_plane.name
}

resource "aws_iam_role_policy_attachment" "service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.control_plane.name
}

data "external" "thumbprint" {
  program = [
    "python3",
    "${path.module}/scripts/oidc_eks_thumbprint.py",
    var.region,
  ]
depends_on = [aws_eks_cluster.primary]
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = aws_eks_cluster.primary.identity.0.oidc.0.issuer
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.primary.name
  addon_name   = "coredns"
  addon_version = var.eks_addon_version[var.k8s_version]["coredns"]
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.primary.name
  addon_name   = "kube-proxy"
  addon_version = var.eks_addon_version[var.k8s_version]["kube-proxy"]
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.primary.name
  addon_name   = "vpc-cni"
  addon_version = var.eks_addon_version[var.k8s_version]["vpc-cni"]
  resolve_conflicts = "OVERWRITE"
}
  
data "aws_eks_cluster_auth" "cluster-auth" {
  name = aws_eks_cluster.primary.name
  
  depends_on = [aws_eks_node_group.primary]
}