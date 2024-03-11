output "api_endpoint" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/${var.lambda_function_name}"
}
