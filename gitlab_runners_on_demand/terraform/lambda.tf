resource "aws_lambda_function" "up" {
  filename         = "${path.module}/../../up_lambda.zip"
  function_name    = "up_pipeline"
  role             = aws_iam_role.lambda.arn
  handler          = "up_lambda"
  source_code_hash = filebase64sha256("${path.module}/../../up_lambda.zip")
  runtime          = "go1.x"
  environment {
    variables = {
      ASGNAME = aws_autoscaling_group.flatcar_runners.name
      UPVAL   = "4"
      DOWNVAL = "0"
      SECRET  = var.webhook_secret
    }
  }
}

resource "aws_lambda_function" "down" {
  filename         = "${path.module}/../../down_lambda.zip"
  function_name    = "down_pipeline"
  role             = aws_iam_role.lambda.arn
  handler          = "down_lambda"
  timeout          = 30
  source_code_hash = filebase64sha256("${path.module}/../../down_lambda.zip")
  runtime          = "go1.x"
  environment {
    variables = {
      ASGNAME     = aws_autoscaling_group.flatcar_runners.name
      GITLABTOKEN = var.gitlab_api_token
    }
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.up.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

resource "aws_lambda_permission" "events" {
  statement_id  = "AllowEventsInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.down.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_hour_15_45.arn
}

resource "aws_cloudwatch_log_group" "up" {
  name              = "/aws/lambda/${aws_lambda_function.up.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "down" {
  name              = "/aws/lambda/${aws_lambda_function.down.function_name}"
  retention_in_days = 14
}