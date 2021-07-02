resource "aws_cloudwatch_event_target" "down" {
  target_id = "down"
  arn       = aws_lambda_function.down.arn
  rule      = aws_cloudwatch_event_rule.every_hour_15_45.name
}

resource "aws_cloudwatch_event_rule" "every_hour_15_45" {
  name                = "every_hour_15_45"
  description         = "Every half hour"
  schedule_expression = "cron(15/30 * * * ? *)"
}