output "lambda_arn" {
  value = aws_lambda_function.lambda_instance.arn
}

output "lambda_exec_role_id" {
  value = aws_iam_role.lambda_exec_role.id
}
