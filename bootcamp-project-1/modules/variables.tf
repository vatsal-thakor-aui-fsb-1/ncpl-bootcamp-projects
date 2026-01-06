# TAGs

variable "project" {
  type        = string
  description = "Project name"
  default     = "Bootcamp-Project-1"
}

variable "owner" {
  type        = string
  description = "Resource owner"
  default     = "vatsal.thakor"
}
variable "cost_center" {
  type        = string
  description = "Cost center"
  default     = "Bootcamp-Project-1-CostCenter"
}

#TAG and Name
variable "environment" {
  type        = string
  description = "Environment (dev, qa, prod)"
  default     = "dev"
}

#Resource
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnet_count" {
  type = number
  description = "Number of public subnets"
  default = 2
}
#ASG
variable "aws_autoscaling_group_desired_inst" {
  type = number
  description = "Number of desired instances"
  default = 2
}

variable "aws_autoscaling_group_min_inst" {
  type = number
  description = "Number of minimum instances"
  default = 2
}

variable "aws_autoscaling_group_max_inst" {
  type = number
  description = "Number of maximum instances"
  default = 3
}

variable "R53_www_record_name" {
  type = string
  description = "Record type www, dev, qa"
  default = "dev"
}
