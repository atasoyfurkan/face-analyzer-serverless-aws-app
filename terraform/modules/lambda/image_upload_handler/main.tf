module "base_lambda" {
  source = "../base_lambda"

  function_name = var.function_name
  handler       = "image_upload_handler.lambda_handler"
  runtime       = "python3.8"
  filename      = "${path.root}/../lambda_functions/image_upload_handler"
  region        = var.region
  env_vars = {
    TABLE_NAME    = var.dynamodb_table_name
    SQS_QUEUE_URL = var.sqs_queue_url
    LOGGING_LEVEL = "INFO"
  }
}

# Lambda access to S3 bucket
resource "aws_iam_role_policy" "lambda_s3_access" {
  role   = module.base_lambda.lambda_exec_role_id
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
  role   = module.base_lambda.lambda_exec_role_id
  policy = data.aws_iam_policy_document.dynamodb_access_policy.json
}

data "aws_iam_policy_document" "dynamodb_access_policy" {
  statement {
    actions   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:UpdateItem"]
    resources = ["${var.dynamodb_table_arn}"]
  }
}

# Lambda queue access to SQS
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
  role       = module.base_lambda.lambda_exec_role_id
  policy_arn = aws_iam_policy.lambda_sqs_access.arn
}
