locals {
  #Make sure you add your lambda arn here
  any_api_ticket_lambda_arn = ""
}

#API Gateway

resource "aws_apigatewayv2_api" "this" {
  name          = "example-http-api"
  description      = "Ticketing HTTP API Gateway"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
  version = 2.0

  tags = {
    managed_by = "Tofu"
  }
}

# Routes

resource "aws_apigatewayv2_route" "any_api_ticket" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /api/ticket"

  target = "integrations/${aws_apigatewayv2_integration.any_api_ticket.id}"
}

# Integrations

resource "aws_apigatewayv2_integration" "any_api_ticket" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  description               = "Lambda ANY/api/ticket"
  integration_method        = "ANY"
  integration_uri           = local.any_api_ticket_lambda_arn

  lifecycle {
    create_before_destroy = true
  }
}

# Stage

resource "aws_apigatewayv2_stage" "this" {
  api_id = aws_apigatewayv2_api.this.id
  name   = "$default"
  auto_deploy = true

  depends_on = [
    aws_apigatewayv2_route.any_api_ticket
  ]
}
