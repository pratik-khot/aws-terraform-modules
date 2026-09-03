data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "aws-tf-org-pk"
    workspaces = {
      name = "vpc-dev"
    }
  }

}