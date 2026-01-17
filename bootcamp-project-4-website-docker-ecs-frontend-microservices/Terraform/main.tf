terraform {
  #Backend State storage and State Locking  
  backend "s3" {
    bucket         = "terraform-remote-state-mangement-bucket"
    key            = "bootcamp-project-4/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-2"

  #Input TAG Variables
  default_tags {
    tags = {
      project     = "Bootcamp-Project-4-Prod"
      environment = "prod"
      owner       = "vatsal.thakor"
      cost_center = "Bootcamp-Project-4-Prod-CostCenter"
    }
  }
}
module "btcmp-project-4-module" {
  source = "./modules"
}
