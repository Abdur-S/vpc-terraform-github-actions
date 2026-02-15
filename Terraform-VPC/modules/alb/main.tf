#ALB module main.tf

resource "aws_lb" "alb" {
  name               = "application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets = var.subnets
}

#Listener for ALB

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
  
}


# Create a target group for the ALB

resource "aws_lb_target_group" "tg" {
  name     = "front-end-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    path                = "/"
    matcher             = "200"
  }
}


# target group attachment 

resource "aws_lb_target_group_attachment" "tg_attachment" {
  count = length(var.instances)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.instances[count.index]
  port             = 80
}
