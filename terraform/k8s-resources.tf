resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "production"
  }
}

resource "kubernetes_config_map" "fluentd" {
    metadata {
        name = "cluster-info"
        namespace = "monitoring"
    }
    data = {
        "cluster.name" = var.cluster_name
        "logs.region"  = var.region
    }
    depends_on = [
        kubernetes_namespace.monitoring
    ]
}