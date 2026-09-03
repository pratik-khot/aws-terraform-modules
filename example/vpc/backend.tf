terraform {

  cloud {
    
    organization = "aws-tf-org-pk"

    workspaces {
      name = "vpc-dev"
    }
  }
}