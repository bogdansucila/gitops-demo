variable "region" {
  type    = string
}

variable "cdn_aliases" {
  type    = set(string)
  default = ["production-web.toptal-project.local"]
}

/*---------------- EKS ----------------*/

variable "cluster_name" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "release_version" {
  type = string
}

variable "eks_addon_version" {
  description = "Addon versions for each EKS version"
  default = {
    "1.21": {"kube-proxy":"v1.21.2-eksbuild.2",
            "vpc-cni":"v1.10.1-eksbuild.1",
            "coredns":"v1.8.4-eksbuild.1",
    },
    "1.20": {"kube-proxy":"v1.20.4-eksbuild.2",
            "vpc-cni":"v1.7.5-eksbuild.2",
            "coredns":"v1.8.3-eksbuild.1",
    }
  }
}

variable "min_node_count" {
  type    = number
  default = 3
}

variable "max_node_count" {
  type    = number
  default = 6
}

variable "machine_type" {
  type    = string
  default = "t3.small"
}

/*---------------- ECR ----------------*/

variable "api_ecr_repo_name" {
  type    = string
  default = "toptal-project-api"
}

variable "web_ecr_repo_name" {
  type    = string
  default = "toptal-project-web"
}

/*---------------- RDS ----------------*/

variable "rds_secrets_arns" {
  type = map(string)
  default = {
    "staging"    = "arn:aws:secretsmanager:eu-west-1:110932912312:secret:staging/rds-secret-dIMSYW",
    "production" = "arn:aws:secretsmanager:eu-west-1:110932912312:secret:production/rds-secret-74iMOZ"
  }
}

variable "rds_allocated_storage" {
  type    = number
  default = 8
}

variable "rds_postgres_engine_version" {
  type    = string
  default = "14.1"
}

variable "rds_instance_class" {
  type = string
  default = "db.t3.micro"
}

variable "rds_db_name" {
  type = string
  default = "api"
}

variable "rds_multi_az" {
  type = bool
  default = false
}

variable "rds_backup_retention_period" {
  type = number
  default = 1
}

variable "skip_rds_final_snapshot" {
  type = bool
  default = true
}
