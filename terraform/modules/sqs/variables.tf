variable "queue_name" {
  description = "The name of the SQS queue"
  type        = string
}

variable "source_arn" {
  description = "The ARN of the source that is allowed to send messages to this queue (e.g., Lambda ARN)"
  type        = string
}
