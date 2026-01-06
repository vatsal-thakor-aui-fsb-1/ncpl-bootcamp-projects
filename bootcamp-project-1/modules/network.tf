#####################
# VPC
#####################

resource "aws_vpc" "btcmp-project-1" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "btcmp-project-1-${var.environment}-custom-vpc"
  }
}

#####################
# Internet Gateway
#####################

resource "aws_internet_gateway" "btcmp-project-1" {
  vpc_id = aws_vpc.btcmp-project-1.id

  tags = {
    Name = "btcmp-project-1-${var.environment}-custom-vpc-igw"
  }
}

#####################
# Public Subnets
#####################

resource "aws_subnet" "btcmp-project-1-public-subnet" {
  count                   = var.vpc_public_subnet_count
  vpc_id                  = aws_vpc.btcmp-project-1.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "btcmp-project-1-${var.environment}-public-subnet-${count.index}"
  }
}

data "aws_availability_zones" "available" {}

#####################
# Route Table
#####################

resource "aws_route_table" "btcmp-project-1-public-route_table" {
  vpc_id = aws_vpc.btcmp-project-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.btcmp-project-1.id
  }

  tags = {
    Name = "btcmp-project-1-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "btcmp-project-1-public-route_table_assoc" {
  count          = var.vpc_public_subnet_count
  subnet_id      = aws_subnet.btcmp-project-1-public-subnet[count.index].id
  route_table_id = aws_route_table.btcmp-project-1-public-route_table.id
}

#####################
# Security Groups
#####################


resource "aws_security_group" "btcmp-project-1-ec2_sg" {
  name   = "btcmp-project-1-${var.environment}-ec2-sg"
  vpc_id = aws_vpc.btcmp-project-1.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#####################
# Application Load Balancer
#####################

resource "aws_lb" "btcmp-project-1" {
  name               = "btcmp-project-1-${var.environment}-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.btcmp-project-1-public-subnet[*].id
  security_groups    = [aws_security_group.btcmp-project-1-ec2_sg.id]
}

resource "aws_lb_target_group" "btcmp-project-1" {
  name     = "btcmp-project-1-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.btcmp-project-1.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.btcmp-project-1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.btcmp-project-1.arn
  }
}

#####################
# Auto Scaling Group
#####################

resource "aws_autoscaling_group" "btcmp-project-1-asg" {
  desired_capacity = var.aws_autoscaling_group_desired_inst
  max_size         = var.aws_autoscaling_group_max_inst
  min_size         = var.aws_autoscaling_group_min_inst

  vpc_zone_identifier = aws_subnet.btcmp-project-1-public-subnet[*].id
  target_group_arns   = [aws_lb_target_group.btcmp-project-1.arn]

  launch_template {
    id      = aws_launch_template.btcmp-project-1-lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "btcmp-project-1-${var.environment}-ec2"
    propagate_at_launch = true
  }
  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
  tag {
    key                 = "Owner"
    value               = var.owner
    propagate_at_launch = true
  }
  tag {
    key                 = "CostCenter"
    value               = var.cost_center
    propagate_at_launch = true
  }
}