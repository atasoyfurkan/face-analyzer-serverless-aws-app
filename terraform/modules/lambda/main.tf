# Lambda basic configuration
data "archive_file" "image_upload_handler" {
  type        = "zip"
  source_file = "${var.filename}.py"
  output_path = "${var.filename}.zip"
}

resource "aws_lambda_function" "image_upload_handler" {
  function_name    = var.function_name
  handler          = var.handler
  runtime          = var.runtime
  role             = aws_iam_role.lambda_exec_role.arn
  filename         = data.archive_file.image_upload_handler.output_path
  source_code_hash = data.archive_file.image_upload_handler.output_base64sha256

  environment {
    variables = {
      TABLE_NAME    = var.dynamodb_table_name
      SQS_QUEUE_URL = var.sqs_queue_url
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.function_name}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
    }],
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Lambda access to S3 bucket
resource "aws_iam_role_policy" "lambda_s3_access" {
  role   = aws_iam_role.lambda_exec_role.id
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${var.s3_bucket_arn}/*"]
  }
}

# Lambda access to DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb_access" {
  role   = aws_iam_role.lambda_exec_role.id
  policy = data.aws_iam_policy_document.dynamodb_access_policy.json
}

data "aws_iam_policy_document" "dynamodb_access_policy" {
  statement {
    actions   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:UpdateItem"]
    resources = ["${var.dynamodb_table_arn}"]
  }
}

# Lambda access to SQS
resource "aws_iam_policy" "lambda_sqs_access" {
  name   = "${var.function_name}_sqs_access"
  policy = data.aws_iam_policy_document.lambda_sqs_access_policy.json
}

data "aws_iam_policy_document" "lambda_sqs_access_policy" {
  statement {
    actions   = ["sqs:SendMessage"]
    resources = [var.sqs_queue_arn]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_access_attachment" {
  role       = aws_iam_role.lambda_exec_role.id
  policy_arn = aws_iam_policy.lambda_sqs_access.arn
}
