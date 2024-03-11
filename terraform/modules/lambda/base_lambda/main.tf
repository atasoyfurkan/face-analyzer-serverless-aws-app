# Lambda basic configuration
data "archive_file" "lambda_instance" {
  type        = "zip"
  source_file = "${var.filename}.py"
  output_path = "${var.filename}.zip"
}

resource "aws_lambda_function" "lambda_instance" {
  function_name    = var.function_name
  handler          = var.handler
  runtime          = var.runtime
  role             = aws_iam_role.lambda_exec_role.arn
  filename         = data.archive_file.lambda_instance.output_path
  source_code_hash = data.archive_file.lambda_instance.output_base64sha256

  environment {
    variables = var.env_vars
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
