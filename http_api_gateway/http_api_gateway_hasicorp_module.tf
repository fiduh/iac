provider "aws" {
  region = local.region
}

locals {
  lambda_arn = "arn:aws:lambda:us-east-1:426991683772:function:demoNodeJS"
  region = "us-east-1"
}



module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "dev-http"
  description   = "Ticketing HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }



  # Routes & Integration(s)
    routes = {

     "ANY /api/auth/{x}" = {
      detailed_metrics_enabled = false

      integration = {
        uri = local.lambda_arn
        payload_format_version = "2.0"
      }
    }

    "ANY /api/ticket" = {
      integration = {
        uri = local.lambda_arn
        type            = "AWS_PROXY"
        payload_format_version = "1.0"
      }
    }

    "ANY /api/ticket/status" = {
      integration = {
        uri = local.lambda_arn
        payload_format_version = "1.0"
      }
    }

    "ANY /api/ticket/archive" = {
      integration = {
        uri = local.lambda_arn
        type            = "AWS_PROXY"
        payload_format_version = "1.0"
      }
    }

    "ANY /api/ticket/reply-email" = {
      integration = {
        uri = local.lambda_arn
        type            = "AWS_PROXY"
        payload_format_version = "1.0"
      }
    }

    "ANY /api/ticket/replyticket" = {
      integration = {
        uri = local.lambda_arn
        type            = "AWS_PROXY"
        payload_format_version = "1.0"
      }
    }
  }



}