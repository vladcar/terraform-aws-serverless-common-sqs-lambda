output "lambda_arn" {
  value = module.lambda.this_lambda_function_arn
}

output "lambda_invoke_arn" {
  value = module.lambda.this_lambda_function_invoke_arn
}

output "lambda_function_name" {
  value = module.lambda.this_lambda_function_name
}