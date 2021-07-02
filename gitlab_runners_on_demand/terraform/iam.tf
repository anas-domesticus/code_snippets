resource "aws_iam_role" "lambda" {
  name               = "gitlab_lambda"
  assume_role_policy = file("${path.module}/iam/lambda_assumerole.json")
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "gitlab_lambda"
  path        = "/"
  description = "IAM policy for logging & ASG manipulation from a lambda"
  policy      = file("${path.module}/iam/lambda_policy.json")
}

resource "aws_iam_role" "gitlab_runner_ec2" {
  name               = "gitlab_runner_ec2"
  assume_role_policy = file("${path.module}/iam/ec2_assumerole.json")
}

resource "aws_iam_policy" "gitlab_runner" {
  name        = "gitlab_runner"
  path        = "/"
  description = "IAM policy for ECR access"
  policy      = file("${path.module}/iam/gitlabrunner_policy.json")
}

resource "aws_iam_role_policy_attachment" "gitlab_runner_ec2" {
  role       = aws_iam_role.gitlab_runner_ec2.name
  policy_arn = aws_iam_policy.gitlab_runner.arn
}

resource "aws_iam_instance_profile" "gitlab" {
  name = "gitlab_runner_ec2"
  role = aws_iam_role.gitlab_runner_ec2.name
}
