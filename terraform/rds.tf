data "aws_secretsmanager_secret" "rds_secrets" {
  for_each = var.rds_secrets_arns
  arn      = each.value
}

data "aws_secretsmanager_secret_version" "rds_secrets" {
  for_each  = var.rds_secrets_arns
  secret_id = data.aws_secretsmanager_secret.rds_secrets[each.key].id
}

resource "aws_db_instance" "rds" {
  for_each                  = var.rds_secrets_arns

  allocated_storage         = var.rds_allocated_storage
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = var.rds_postgres_engine_version
  instance_class            = var.rds_instance_class
  db_name                   = var.rds_db_name
  db_subnet_group_name      = aws_db_subnet_group.rds.name
  vpc_security_group_ids    = [aws_security_group.rds[each.key].id]
  identifier                = "${each.key}-${var.cluster_name}-rds"
  multi_az                  = var.rds_multi_az
  backup_retention_period   = var.rds_backup_retention_period
  skip_final_snapshot       = var.skip_rds_final_snapshot
  final_snapshot_identifier = "${each.key}-${var.cluster_name}-rds-final-snapshot"

  username = jsondecode(data.aws_secretsmanager_secret_version.rds_secrets[each.key].secret_string)["db_user"]
  password = jsondecode(data.aws_secretsmanager_secret_version.rds_secrets[each.key].secret_string)["db_pass"]
}

