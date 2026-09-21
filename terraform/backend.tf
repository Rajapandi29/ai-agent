terraform {
  backend "s3" {
    bucket       = "terraform-state-10-09"
    key          = "ai-agent/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}