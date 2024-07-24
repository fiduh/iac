# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

# Lambda Function
resource "aws_lambda_function" "this" {
  function_name = "HelloWorldFunction"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
}
