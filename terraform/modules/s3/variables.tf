variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "The ARN of the Lambda function"
  type        = string
}

variable "lambda_trigger_filter_prefix" {
  description = "The prefix to use for the lambda function trigger when uploading files"
  type        = string
}

variable "lambda_trigger_filter_suffix" {
  description = "The suffix to use for the lambda function trigger when uploading files"
  type        = string
}
