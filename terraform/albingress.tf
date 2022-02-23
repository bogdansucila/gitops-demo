resource "aws_iam_role" "alb_ingress_service_role" {
  name               = "ALBIngressRole"
  assume_role_policy = templatefile("${path.module}/templates/oidc_assume_role_policy.json", { OIDC_ARN = aws_iam_openid_connect_provider.cluster.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.cluster.url, "https://", ""), NAMESPACE = "kube-system", SA_NAME = "aws-load-balancer-controller" })
  depends_on         = [aws_iam_openid_connect_provider.cluster]
}

data "http" "alb_ingress_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/main/docs/install/iam_policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_iam_role_policy" "alb_ingress" {
  name   = "alb_policy"
  role   = aws_iam_role.alb_ingress_service_role.name
  policy = data.http.alb_ingress_policy.body
}
