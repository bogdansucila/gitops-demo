resource "kubernetes_secret" "api_rds_secrets" {
  for_each = var.rds_secrets_arns

  metadata {
    name      = "${each.key}-toptal-project-rds-secrets"
    namespace = each.key
  }

  data = {
    DBUSER = jsondecode(data.aws_secretsmanager_secret_version.rds_secrets[each.key].secret_string)["db_user"]
    DBPASS = jsondecode(data.aws_secretsmanager_secret_version.rds_secrets[each.key].secret_string)["db_pass"]
  }

  depends_on = [
    kubernetes_namespace.prod,
    kubernetes_namespace.staging
  ]
}