data "aws_lb" "k8s_alb" {
  tags ={
    "elbv2.k8s.aws/cluster" = var.cluster_name
  }
}

resource "random_string" "origin_token" {
  length  = 30
  special = false
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name   = data.aws_lb.k8s_alb.arn
    origin_id     = "alb"
    custom_header {
      name = "X-Origin-Token"
      value = random_string.origin_token.result
    }
  }

  enabled = true
  aliases = var.cdn_aliases

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb"

    forwarded_values {
      query_string = true
      headers        = ["X-Origin-Token"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"] # Sample geo-restriction
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [
    helm_release.argocd
  ]
}

data "aws_ip_ranges" "cloudfront" {
    services = ["cloudfront"]
}

data "aws_security_group" "k8s_alb" {
  tags ={
    "ingress.k8s.aws/resource" = "ManagedLBSecurityGroup"
  }
}

resource "aws_security_group_rule" "k8s_alb_allow_cloudfront" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = data.aws_ip_ranges.cloudfront.cidr_blocks
  security_group_id        = data.aws_security_group.k8s_alb.id
}