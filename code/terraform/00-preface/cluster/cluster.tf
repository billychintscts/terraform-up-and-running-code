terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version =  "~> 3.0"
    }
  }

  required_version = ">= 1.0.2"
}

provider "aws" {
  region = "us-east-1"

# can also specify here       version = "~> 3.0"
}

# ALG 
resource "aws_launch_configuration" "example" {
  image_id        = "ami-09e67e426f25ce0d7"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.alb.id]
 

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p var.server_port &
              EOF
  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

# ASG
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  # to pull all the subnets
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids
  # identify the target groups step 7
  target_group_arns = [aws_lb_target_group.asg.arn]
  # default is EC2
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

data "aws_vpc" "default" {
  default = true
}
# get the subnets from default vpc
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# 1 create ALB
resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  # load balance, fail over all available subnets
  subnets            = data.aws_subnet_ids.default.ids
  # step 4, handle the traffics
  security_groups    = [aws_security_group.alb.id]  
}

#2 create ALB listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# 3 need to configure security groups to handle incoming outgoing traffic
#   aws resource not handling the traffic

resource "aws_security_group" "alb" {
  name = "terraform-example-alb"

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4 ALB to use this security group
# 5 create the targer group
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 6 create target group
# 7 listener rule
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

