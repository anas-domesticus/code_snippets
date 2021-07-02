resource "aws_launch_configuration" "flatcar_runner" {
  name_prefix                 = "runner-on-demand-"
  image_id                    = data.aws_ami.flatcar.id
  instance_type               = "t3.small"
  security_groups             = [aws_security_group.allow_ssh.id]
  user_data                   = data.template_file.user_data.rendered
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.gitlab.name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "flatcar_runners" {
  name_prefix          = "flatcar_runners"
  launch_configuration = aws_launch_configuration.flatcar_runner.name
  health_check_type    = "EC2"
  min_size             = 0
  desired_capacity     = 4
  max_size             = 5
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [aws_subnet.main.id]
}

resource "aws_autoscaling_schedule" "reset" { # This spins down any & all runners every night
  scheduled_action_name  = "reset-to-0"
  min_size               = 0
  max_size               = 5
  desired_capacity       = 0
  recurrence             = "0 0 * * *" # Midnight, every night
  autoscaling_group_name = aws_autoscaling_group.flatcar_runners.name
}