data "aws_region" "current" {}
data "aws_caller_identity" "identity" {}

module "lambda" {
  source                       = "terraform-aws-modules/lambda/aws"
  function_name                = var.function_name
  handler                      = var.handler
  runtime                      = var.runtime
  publish                      = false
  layers                       = var.layers
  timeout                      = 30
  create_async_event_config    = true
  maximum_event_age_in_seconds = 120
  maximum_retry_attempts       = 0
  environment_variables        = var.env_vars
  attach_policies              = true
  policies                     = concat(var.attached_policies, [aws_iam_policy.sqs_policy.arn])

  #todo check this out
  create_package         = false
  local_existing_package = var.file_name
}

resource "aws_lambda_event_source_mapping" "event_source" {
  event_source_arn = var.event_queue_arn
  function_name    = module.lambda.this_lambda_function_arn
  batch_size       = 10 # 10 is default but we set it here for clarity
}

resource "aws_iam_policy" "sqs_policy" {
  name_prefix = var.function_name
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
