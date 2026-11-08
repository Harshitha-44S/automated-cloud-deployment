# Package Python Lambda code into ZIP
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/s3_trigger.py"
  output_path = "${path.module}/lambda_function.zip"
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "cloud-deployment-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

# Allow Lambda to write logs
resource "aws_iam_role_policy" "lambda_logs" {
  name = "lambda-cloudwatch-logs"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]

      Resource = "arn:aws:logs:ap-south-1:*:log-group:/aws/lambda/cloud-file-upload-processor:*"
    }]
  })
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/cloud-file-upload-processor"
  retention_in_days = 7
}

# Create Lambda Function
resource "aws_lambda_function" "s3_processor" {
  function_name = "cloud-file-upload-processor"

  role    = aws_iam_role.lambda_role.arn
  handler = "s3_trigger.lambda_handler"
  runtime = "python3.12"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 10
  memory_size = 128

  depends_on = [
    aws_iam_role_policy.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs
  ]

  tags = {
    Name = "cloud-file-upload-processor"
  }
}

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.app_storage.arn
}

# Configure S3 upload notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.app_storage.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}