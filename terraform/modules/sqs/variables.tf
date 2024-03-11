variable "queue_name" {
  description = "The name of the SQS queue"
  type        = string
}

variable "source_lambda_arn" {
  description = "The ARN of the source that is allowed to send messages to this queue (e.g., Lambda ARN)"
  type        = string
}

variable "trigger_lambda_arn" {
  description = "The ARN of the resource that triggers the Lambda function"
  type        = string
}
