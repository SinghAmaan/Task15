# ---------------------------
# Load Balancer (ALB)
# ---------------------------
resource "aws_lb" "batch3_alb" {
  name               = "BATCH3-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.alb_public[*].id

  tags = {
    Name = "BATCH3-ALB"
  }
}

# ---------------------------
# Target Group
# ---------------------------
resource "aws_lb_target_group" "batch3_tg" {
  name        = "BATCH3-ALB-TG"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.aws_final_project.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-400"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "BATCH3-ALB-TG"
  }
}

# ---------------------------
# ALB Listener
# ---------------------------
resource "aws_lb_listener" "batch3_listener" {
  load_balancer_arn = aws_lb.batch3_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.batch3_tg.arn
  }
}
