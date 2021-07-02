resource "aws_api_gateway_rest_api" "this" {
  name = "Gitlab ASG API"
}

resource "aws_api_gateway_resource" "pipeline" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "up_pipeline"
}

resource "aws_api_gateway_method" "pipelineMethod" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.pipeline.id
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.pipelineMethod.resource_id
  http_method = aws_api_gateway_method.pipelineMethod.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.up.invoke_arn
}

resource "aws_api_gateway_deployment" "apideploy" {
  depends_on = [
    aws_api_gateway_integration.this,
  ]
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = "prod"
}
