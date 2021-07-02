data "aws_ami" "flatcar" {
  most_recent = true
  filter {
    name = "name"
    values = [
    "Flatcar-stable-*"]
    # Always gets the latest stable image
  }
  filter {
    name = "virtualization-type"
    values = [
    "hvm"]
  }
  owners = ["075585003325"] # Flatcar's AWS account
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data/init.sh")
  vars = {
    unitfile = templatefile("${path.module}/user_data/gitlab-runner.service",
      {
        token       = var.gitlab_token,
        concurrency = "2",
    }),
    configscript = templatefile("${path.module}/user_data/config.sh",
      {
        concurrency = "2"
    }),
  }
}
