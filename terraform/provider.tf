provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    host                      = aws_eks_cluster.primary.endpoint
    cluster_ca_certificate    = base64decode(aws_eks_cluster.primary.certificate_authority.0.data)
    token                     = data.aws_eks_cluster_auth.cluster-auth.token
  }
}

provider "kubernetes" {
  host                      = aws_eks_cluster.primary.endpoint
  cluster_ca_certificate    = base64decode(aws_eks_cluster.primary.certificate_authority.0.data)
  token                     = data.aws_eks_cluster_auth.cluster-auth.token
}