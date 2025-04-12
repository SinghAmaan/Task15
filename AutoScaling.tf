resource "aws_autoscaling_group" "batch3_asg" {
  name                      = "BATCH3-ASG"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = aws_subnet.app_private[*].id
  target_group_arns         = [aws_lb_target_group.batch3_tg.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 30

  launch_template {
    id      = aws_launch_template.batch3_template.id
    version = "$Latest"
  }

  tag{
    key                 = "Name"
    value               = "BATCH3-App-Instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_launch_template.batch3_template] # ✅ Launch Template must finish first
}