provider "aws" {
  region = "eu-west-3"  
}

# Archive the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/index.js"
  output_path = "${path.module}/lambda_function.zip"
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "g5_lambda_a"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create Lambda function
resource "aws_lambda_function" "paris_time_lambda" {
  function_name    = "g5_lambda_a"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 10

  environment {
    variables = {
      TIMEZONE = "Europe/Paris"
    }
  }
}

# Create API Gateway to expose Lambda
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "g5_api_a"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.lambda_api.id
  integration_type = "AWS_PROXY"
  
  integration_uri    = aws_lambda_function.paris_time_lambda.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "GET /time"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.paris_time_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  dashboard_name = "g5_dashboard_a"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "g5_lambda"],
            ["AWS/Lambda", "Errors", "FunctionName", "g5_lambda"],
            ["AWS/Lambda", "Duration", "FunctionName", "g5_lambda"]
          ]
          period = 300
          stat   = "Sum"
          region = "eu-west-3"
          title  = "Lambda Metrics"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          query = "SOURCE '/aws/lambda/g5_lambda_a' | fields @timestamp, @message | filter @message like 'Hi there'",
          region = "eu-west-3",
          title  = "Lambda Logs - Hi there Messages",
          view   = "table"
        }
      }
    ]
  })
}


# Output the API endpoint URL
output "api_endpoint" {
  value = "${aws_apigatewayv2_stage.lambda_stage.invoke_url}/time"
}

output "cloudwatch_dashboard_url" {
  value = "https://eu-west-3.console.aws.amazon.com/cloudwatch/home?region=eu-west-3#dashboards:name=${aws_cloudwatch_dashboard.lambda_dashboard.dashboard_name}"
}
