provider "aws" {
  region = "us-east-1"
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

}


# Lambda Function
resource "aws_lambda_function" "this" {
  function_name = "lambdaFunction"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
}



#   data "aws_iam_policy_document" "lambda_logging" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]

#     resources = ["*"]
#   }
# }

# resource "aws_iam_policy" "lambda_logging" {
#   name        = "lambda_logging"
#   path        = "/"
#   description = "IAM policy for logging from a lambda"
#   policy      = data.aws_iam_policy_document.lambda_logging.json
# }

# resource "aws_iam_role_policy_attachment" "lambda_logs" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_logging.arn
# }