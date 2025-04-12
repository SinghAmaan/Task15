resource "aws_launch_template" "batch3_template" {
  name_prefix   = "batch3-launch-template-"
  image_id      = aws_ami_from_instance.jumpserver_ami.id
  instance_type = "t2.micro"
  key_name      = "AWS-FINAL-PROJECT"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "BATCH3-App-Instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_ami_from_instance.jumpserver_ami]# ✅ AMI must finish first
}
