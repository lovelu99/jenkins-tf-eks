terraform {
  backend "s3" {
    bucket       = "lovelu-s3-remoteback"
    key          = "prod/vpc/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true

  }

}