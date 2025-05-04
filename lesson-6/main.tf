locals {
  user_data_hash = filesha256("user_data.sh")
  az1_name       = data.aws_availability_zones.available.names[0]
  az2_name       = data.aws_availability_zones.available.names[1]
  inactive_color = var.active_color == "green" ? "blue" : "green"
}


# --------------------- LAUNCH TEMPLATES ---------------------
resource "aws_launch_template" "web_template_green" {
  count             = var.active_color == "green" ? 1 : 0
  name_prefix       = "web-template-green-"
  image_id          = data.aws_ami.latest_amazon_linux.id
  instance_type     = "t2.micro"
  user_data         = filebase64("user_data.sh")
  vpc_security_group_ids = [data.aws_security_group.my_webserver.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name         = "web-asg-green-instance"
      UserDataHash = local.user_data_hash
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "web_template_blue" {
  count             = var.active_color == "blue" ? 1 : 0
  name_prefix       = "web-template-blue-"
  image_id          = data.aws_ami.latest_amazon_linux.id
  instance_type     = "t2.micro"
  user_data         = filebase64("user_data.sh")
  vpc_security_group_ids = [data.aws_security_group.my_webserver.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name         = "web-asg-blue-instance"
      UserDataHash = local.user_data_hash
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------- LOAD BALANCER ---------------------
resource "aws_lb" "app_lb" {
  name               = "web-bluegreen-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.my_webserver.id]
  subnets            = [data.aws_subnet.subnet_az1.id, data.aws_subnet.subnet_az2.id]
  enable_deletion_protection = false

  tags = {
    Name = "BlueGreen-ALB"
  }
}

# --------------------- TARGET GROUPS ---------------------
resource "aws_lb_target_group" "tg_green" {
  name     = "tg-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "tg_blue" {
  name     = "tg-blue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# --------------------- AUTO SCALING GROUPS ---------------------
resource "aws_autoscaling_group" "web_asg_green" {
  count               = var.active_color == "green" ? 1 : 0
  name_prefix         = "web-asg-green-"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  vpc_zone_identifier = [data.aws_subnet.subnet_az1.id, data.aws_subnet.subnet_az2.id]

  launch_template {
    id      = aws_launch_template.web_template_green[0].id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg_green.arn]

  tag {
    key                 = "UserData-Hash"
    value               = local.user_data_hash
    propagate_at_launch = false
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_asg_blue" {
  count               = var.active_color == "blue" ? 1 : 0
  name_prefix         = "web-asg-blue-"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  vpc_zone_identifier = [data.aws_subnet.subnet_az1.id, data.aws_subnet.subnet_az2.id]

  launch_template {
    id      = aws_launch_template.web_template_blue[0].id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg_blue.arn]

  tag {
    key                 = "UserData-Hash"
    value               = local.user_data_hash
    propagate_at_launch = false
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------- LISTENER ---------------------
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.active_color == "green" ? aws_lb_target_group.tg_green.arn : aws_lb_target_group.tg_blue.arn
  }
}