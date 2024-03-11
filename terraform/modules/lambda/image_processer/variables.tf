variable "function_name" {
  description = "Name of the Lambda function"
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket that the Lambda function will access"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table that the Lambda function will access"
  type        = string
}

variable "sqs_queue_arn" {
  description = "The ARN of the SQS queue that the Lambda function will access"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table that the Lambda function will access"
  type        = string
}
