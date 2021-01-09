
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
  create_role                    = var.create_role
  execution_role                 = var.execution_role
  attached_policies              = var.create_role ? concat(var.attached_policies, [aws_iam_policy.sqs_policy[0].arn]) : []
  enable_vpc_config              = var.enable_vpc_config
  security_group_ids             = var.security_group_ids
  subnet_ids                     = var.subnet_ids
  tracing_mode                   = var.tracing_mode
}

resource "aws_lambda_event_source_mapping" "event_source" {
  event_source_arn = var.event_queue_arn
  function_name    = module.lambda.lambda_arn
  batch_size       = 10 # 10 is default but we set it here for clarity
}

resource "aws_iam_policy" "sqs_policy" {
  count       = var.create_role ? 1 : 0
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
