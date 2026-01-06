#####################
# Launch Template
#####################


resource "aws_launch_template" "btcmp-project-1-lt" {
  name_prefix   = "btcmp-project-1-${var.environment}-lt-"
  image_id      = "ami-0ac21b6c51f4491e9"
  instance_type = "t2.micro"
  key_name      = "EC2-KEY"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.btcmp-project-1-ec2_sg.id]
  }
}