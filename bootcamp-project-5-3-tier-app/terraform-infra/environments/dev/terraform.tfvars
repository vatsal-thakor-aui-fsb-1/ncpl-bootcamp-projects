# Example values for development environment
# Copy this file to terraform.tfvars and adjust values

region      = "us-east-2"
environment = "dev"
project     = "btcmp-proj-5"

# Network Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-2a", "us-east-2b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
frontend_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
backend_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]
database_subnet_cidrs = ["10.0.31.0/24", "10.0.32.0/24"]
single_nat_gateway   = true  # false for high availability

# SSH Configuration
ssh_key_name     = "EC2-KEY"  
allowed_ssh_cidr = "0.0.0.0/0"          # CHANGE to your IP address like for security"

# Bastion Configuration
bastion_instance_type = "t2.micro"

# Frontend ASG Configuration
frontend_instance_type    = "t2.micro"
frontend_min_size         = 1
frontend_max_size         = 2
frontend_desired_capacity = 1

# Backend ASG Configuration
backend_instance_type    = "t2.micro"
backend_min_size         = 1
backend_max_size         = 2
backend_desired_capacity = 1

# RDS Configuration
db_instance_class       = "db.t3.micro"
db_allocated_storage    = 20
db_engine_version       = "15.15"
db_name                 = "goalsdb"
db_username             = "postgres"
db_multi_az             = false  # true for high availability
db_backup_retention     = 7
db_skip_final_snapshot  = true   # false for production

# Docker Hub Configuration
frontend_docker_image = "vatsal79/btcmp-proj-5-frontend:latest"
backend_docker_image  = "vatsal79/btcmp-proj-5-backend:latest"
dockerhub_username    = ""  # Leave empty for public images
dockerhub_password    = ""  # Leave empty for public images, or use access token

# Tags
tags = {
  Environment = "dev"
  Project     = "btcmp-proj-5"
  CostCenter  = "btcmp-proj-5"
  Owner       = "Vatsal"
}
