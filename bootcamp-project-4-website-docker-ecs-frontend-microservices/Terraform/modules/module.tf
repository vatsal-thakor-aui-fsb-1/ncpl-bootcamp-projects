###PROVIDER

provider "aws" {
  region = "us-east-2"
}

###DATA

data "aws_availability_zones" "available" {}

###VPC

resource "aws_vpc" "btcmp-proj-4-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "btcmp-proj-4-vpc" }
}

###SUBNETS

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.btcmp-proj-4-vpc.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "public-${count.index}" }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.btcmp-proj-4-vpc.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "private-${count.index}" }
}


###INTERNET + NAT

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.btcmp-proj-4-vpc.id
}

resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}


###ROUTE TABLES

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.btcmp-proj-4-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.btcmp-proj-4-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


###ALB

resource "aws_lb" "alb" {
  name               = "btcmp-proj-4-ecs-express-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.btcmp-proj-4-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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




resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "404"
      content_type = "text/plain"
    }
  }
}

resource "aws_lb_target_group" "frontend1" {
  name        = "frontend1-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.btcmp-proj-4-vpc.id
  target_type = "ip"
}
resource "aws_lb_target_group" "frontend2" {
  name        = "frontend2-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.btcmp-proj-4-vpc.id
  target_type = "ip"
}

resource "aws_lb_listener_rule" "frontend1" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend1.arn
  }

  condition {
    path_pattern {
      values = ["/frontend1*"]
    }
  }
}
resource "aws_lb_listener_rule" "frontend2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend2.arn
  }

  condition {
    path_pattern {
      values = ["/frontend2*"]
    }
  }
}



###IAM EXECUTION ROLE

/*resource "aws_iam_role" "ecs_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}*/

data "aws_iam_role" "existing_ecs_execution_role" {
  name = "ecsTaskExecutionRole" ###As this role already exists in the account
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = data.aws_iam_role.existing_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

###ECS CLUSTER (EXPRESS STYLE – SIMPLE)

resource "aws_ecs_cluster" "this" {
  name = "btcmp-proj-4-ecs-frontend-cluster"
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.btcmp-proj-4-vpc.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###TASK DEFINITIONS

resource "aws_ecs_task_definition" "frontend1" {
  family                   = "frontend1"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.existing_ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "frontend1"
      image = "419126140774.dkr.ecr.us-east-2.amazonaws.com/vatsal/repo:frontend1"
      portMappings = [{
        containerPort = 3000
      }]
    }
  ])
}

resource "aws_ecs_task_definition" "frontend2" {
  family                   = "frontend2"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.existing_ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "frontend2"
      image = "419126140774.dkr.ecr.us-east-2.amazonaws.com/vatsal/repo:frontend2"
      portMappings = [{
        containerPort = 3000
      }]
    }
  ])
}

###ECS SERVICE (PRIVATE SUBNET, MIN 2)

resource "aws_ecs_service" "frontend1" {
  name            = "btcmp-proj-4-ecs-frontend1-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend1.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend1.arn
    container_name   = "frontend1"
    container_port   = 3000
  }
}

resource "aws_ecs_service" "frontend2" {
  name            = "btcmp-proj-4-ecs-frontend2-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend2.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend1.arn
    container_name   = "frontend2"
    container_port   = 3000
  }
}


###AUTOSCALING

resource "aws_appautoscaling_target" "frontend1" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.frontend1.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 2
  max_capacity       = 3
}
resource "aws_appautoscaling_target" "frontend2" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.frontend2.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 2
  max_capacity       = 3
}

resource "aws_appautoscaling_policy" "frontend1_cpu" {
  name               = "frontend1_cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend1.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend1.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend1.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "frontend2_cpu" {
  name               = "frontend1_cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend2.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend2.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend2.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 80
  }
}

output "alb_dns" {
  value = aws_lb.alb.dns_name
}