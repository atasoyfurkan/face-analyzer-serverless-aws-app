variable "api_name" {
  description = "The name of the API Gateway"
}

variable "invoke_lambda_arn" {
  description = "The ARN to invoke the Lambda"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
}

variable "region" {
  description = "The region in which the resources will be created"
}

variable "stage_name" {
  description = "The name of the stage (version of the API Gateway)"
}
