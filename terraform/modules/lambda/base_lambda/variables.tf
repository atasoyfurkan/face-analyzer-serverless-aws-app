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

variable "env_vars" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
}
