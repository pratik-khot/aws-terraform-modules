data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = var.vpc_remote_state_organization
    workspaces = {
      name = var.vpc_remote_state_workspace
    }
  }
}