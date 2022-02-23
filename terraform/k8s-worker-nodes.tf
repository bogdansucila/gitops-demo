resource "aws_eks_node_group" "primary" {
  cluster_name    = aws_eks_cluster.primary.name
  version         = var.k8s_version
  release_version = var.release_version
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = aws_subnet.worker[*].id
  instance_types  = [var.machine_type]

  scaling_config {
    desired_size = var.min_node_count
    max_size     = var.max_node_count
    min_size     = var.min_node_count
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.registry,
  ]

  timeouts {
    create = "15m"
    update = "1h"
  }
}

resource "aws_iam_role" "worker" {
  name = "${title(var.cluster_name)}-Worker"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}
