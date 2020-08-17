locals {
    lambda_zip_location = "${path.module}/files/instance_protection.zip"
}

data "archive_file" "instance_protection" {
  type        = "zip"
  source_file = "${path.module}/instance_protection.py"
  output_path = local.lambda_zip_location
}

resource "aws_lambda_function" "instance_protection" {
  filename      = local.lambda_zip_location
  function_name = "instance_protection"
  role          = var.lambda_role
  handler       = "instance_protection.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(local.lambda_zip_location)

  runtime = "python3.6"
}

resource "aws_cloudwatch_event_rule" "instance_protection" {
  name                = "instance_protection"
  description         = "Fires every one minutes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_one_minute" {
  rule      = aws_cloudwatch_event_rule.instance_protection.name
  target_id = "lambda"
  arn       = aws_lambda_function.instance_protection.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_instance_protection" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.instance_protection.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.instance_protection.arn
}