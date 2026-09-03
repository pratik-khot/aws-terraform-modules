terraform {
  backend "remote" {
    organization = "tfc-pratik-khot"

    workspaces {
      name = "Dev"
    }
  }
}