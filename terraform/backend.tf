terraform {
  backend "s3" {
    bucket  = "toptal-project"
    key     = "terraform/dev"
    region  = "eu-west-1"
  }
}
