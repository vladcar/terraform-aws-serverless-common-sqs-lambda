
module "lambda" {
  source                         = "vladcar/serverless-common-basic-lambda/aws"
  source_path                    = var.source_path
  function_name                  = var.function_name
  handler                        = var.handler
  memory_size                    = var.memory_size
  description                    = var.description
  reserved_concurrent_executions = var.reserved_concurrent_executions
  timeout                        = var.timeout
  create_async_invoke_config     = var.create_async_invoke_config
  maximum_event_age_in_seconds   = var.maximum_event_age_in_seconds
  maximum_retry_attempts         = var.maximum_retry_attempts
  destination_on_failure         = var.destination_on_failure
  destination_on_success         = var.destination_on_success
  runtime                        = var.runtime
  layers                         = var.layers
  env_vars                       = var.env_vars
  tags                           = var.tags
  attached_policies              = concat(var.attached_policies, [aws_iam_policy.sqs_policy.arn])
}

resource "aws_lambda_event_source_mapping" "event_source" {
  event_source_arn = var.event_queue_arn
  function_name    = module.lambda.lambda_arn
  batch_size       = 10 # 10 is default but we set it here for clarity
}

resource "aws_iam_policy" "sqs_policy" {
  name_prefix = "LambdaSqsPolicy"
  policy      = data.aws_iam_policy_document.sqs_policy_doc.json
}

data "aws_iam_policy_document" "sqs_policy_doc" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage"
    ]
    resources = [
      var.event_queue_arn
    ]
  }
}
