terraform {
  backend "s3" {
    bucket       = "terraform-state-devops-prj"
    key          = "example/eks/env/dev/terraform.tfstate"
    use_lockfile = true

  }
}