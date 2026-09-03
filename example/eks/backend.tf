terraform {
  cloud {

    organization = "aws-tf-org-pk"

    workspaces {
      name = "eks-dev"
    }
  }
}