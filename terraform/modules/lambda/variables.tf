variable "function_name" {
  description = "Name of the Lambda function"
}

variable "handler" {
  description = "The function entrypoint in your code"
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
}

variable "filename" {
  description = "The path to the function's deployment package"
}

variable "region" {
  description = "The AWS region"
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket that the Lambda function will access"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table that the Lambda function will access"
  type        = string
}
