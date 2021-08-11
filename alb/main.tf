###################################################
#security group for ALB
################################################


resource "aws_security_group" "ALB-SG" {
  name   = "DevopsTest_ALB-SG"
  vpc_id = var.vpc_id

  #http access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #https access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {

    Name        = "DevopsTest-ALB-SG"
    Environment = var.environment_tag
  }
}


#################################3
###### ALB
########################################

resource "aws_lb" "DevopsTestLB" {
  name                             = var.lb_name
  internal                         = var.lb_internal
  load_balancer_type               = var.load_balancer_type
  security_groups                  = [aws_security_group.ALB-SG.id]
  subnets                          = var.DevopsTestSubnetPublic.*.id
  enable_deletion_protection       = var.lb_enable_deletion_protection
  enable_cross_zone_load_balancing = var.lb_enable_cross_zone_load_balancing
  enable_http2                     = var.lb_enable_http2

  tags = {
    Name        = "DevopsTestLB"
    Environment = var.environment_tag
  }
}

###################################
## Target Group
################################
resource "aws_lb_target_group" "main" {
  name                          = "DevopsTest-http-TG"
  port                          = 80
  protocol                      = "HTTP"
  target_type                   = "ip"
  load_balancing_algorithm_type = "round_robin"
  vpc_id                        = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = 200
  }
}


#####################################
### LB listeners
#####################################

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.DevopsTestLB.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.DevopsTestLB.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

