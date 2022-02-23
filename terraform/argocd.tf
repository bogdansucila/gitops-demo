resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "3.33.0"

  values = [
    file("${path.module}/templates/argocd.yaml")
  ]
}

resource "aws_iam_role" "argocd_service_role" {
  name               = "ArgoCDRole"
  assume_role_policy = templatefile("${path.module}/templates/oidc_assume_role_policy.json", { OIDC_ARN = aws_iam_openid_connect_provider.cluster.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.cluster.url, "https://", ""), NAMESPACE = "argocd", SA_NAME = "argocd-server" })
  depends_on         = [aws_iam_openid_connect_provider.cluster]
}

data "aws_ecr_repository" "api" {
  name = var.api_ecr_repo_name
}

data "aws_ecr_repository" "web" {
  name = var.web_ecr_repo_name
}

data "aws_iam_policy_document" "argocd_iam_policy_document" {
  statement {
    sid = "ECRPermissions"

    actions = [
      "ecr:*"
    ]

    resources = [
      "${data.aws_ecr_repository.api.arn}",
      "${data.aws_ecr_repository.web.arn}"
    ]
  }
}

resource "aws_iam_role_policy" "argocd_iam_policy" {
  name   = "argocd_policy"
  role   = aws_iam_role.argocd_service_role.name
  policy = data.aws_iam_policy_document.argocd_iam_policy_document.json
}
