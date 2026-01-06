terraform {
  #Backend State storage and State Locking  
  backend "s3" {
    bucket         = "terraform-remote-state-mangement-bucket"
    key            = "bootcamp-project-1/prod/terraform.tfstate"
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
      project     = "Bootcamp-Project-1-Prod"
      environment = "prod"
      owner       = "vatsal.thakor"
      cost_center = "Bootcamp-Project-1-Prod-CostCenter"
    }
  }
}
module "btcmp-project-1-module" {
  source = "../modules"

  #Variables
  vpc_cidr                           = "10.1.0.0/16"
  vpc_public_subnet_count            = 3
  aws_autoscaling_group_desired_inst = 2
  aws_autoscaling_group_min_inst     = 2
  aws_autoscaling_group_max_inst     = 3

  #Input TAG Variables- For ASG
  project     = "Bootcamp-Project-1-Prod"
  environment = "prod"
  owner       = "vatsal.thakor"
  cost_center = "Bootcamp-Project-1-Prod-CostCenter"

  #R53
  R53_www_record_name = "www"
}
