locals {
  es_domain        = "example" # Hard-coded until the next TF version
  es_version       = "6.5"    # Hard-coded until the next TF version
  venv_directory   = "/tmp/es_curator"
  lambda_directory = "../../lambda/elasticsearch_curator"
  lambda_publish   = true
  lambda_timeout   = 60
  lambda_name      = split(".", "es_curator.py")[0]
  lambda_runtime   = "python3.7"
  lambda_tags = {
    "es/domain"      = local.es_domain
    "es/version"     = local.es_version
    "lambda/runtime" = local.lambda_runtime
    "lambda/name"    = local.lambda_name
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "elasticsearch_log_publishing_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = ["arn:aws:logs:*"]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "null_resource" "lambda" {
  triggers = {
    handler      = "${base64sha256(file("${local.lambda_directory}/requirements.txt"))}"
    requirements = "${base64sha256(file("${local.lambda_directory}/${local.lambda_name}.py"))}"
  }

  provisioner "local-exec" {
    command = <<EOF
    if [[ -d "${local.venv_directory}" ]]; then rm -rf "${local.venv_directory}"; fi;
    mkdir -p "${local.venv_directory}/archive";
    cp "${local.lambda_directory}/${local.lambda_name}.py" "${local.venv_directory}/archive";
    $(which python3.7) -m venv "${local.venv_directory}" && source "${local.venv_directory}/bin/activate";
    $(which pip) install --upgrade --target "${local.venv_directory}/archive" -r "${local.lambda_directory}/requirements.txt";
    EOF
    interpreter = ["bash", "-c"]
  }
}

data "archive_file" "lambda" {
  depends_on = ["null_resource.lambda"]

  source_dir  = "${local.venv_directory}/archive"
  output_path = "${local.lambda_name}.zip"
  type        = "zip"
}

resource "aws_lambda_function" "curator" {
  description      = "Managed by Terraform - Curator lambda for Elasticsearch"
  filename         = data.archive_file.lambda.output_path
  function_name    = local.lambda_name
  role             = aws_iam_role.curator.arn
  runtime          = local.lambda_runtime
  timeout          = local.lambda_timeout
  handler          = "${local.lambda_name}.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  publish          = local.lambda_publish

  tags             = merge(var.global_tags, local.lambda_tags)

  lifecycle {
    ignore_changes = ["source_code_hash", "last_modified"]
  }
}

resource "aws_lambda_permission" "curator" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.curator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.curator.arn
}

resource "aws_cloudwatch_log_group" "curator" {
  name              = "/aws/lambda/${aws_lambda_function.curator.function_name}"
  retention_in_days = 14

  tags              = merge(var.global_tags, local.lambda_tags)
}

resource "aws_cloudwatch_event_rule" "curator" {
  name                = "${aws_lambda_function.curator.function_name}"
  description         = "trigger curator lambda"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "curator" {
  rule      = aws_cloudwatch_event_rule.curator.name
  target_id = aws_lambda_function.curator.function_name
  arn       = aws_lambda_function.curator.arn
}

resource "aws_cloudwatch_log_resource_policy" "curator" {
  policy_document = data.aws_iam_policy_document.elasticsearch_log_publishing_policy.json
  policy_name     = "elasticsearch-log-publishing-policy"
}

resource "aws_iam_role" "curator" {
  name               = "${local.lambda_name}_role"
  description        = "${local.lambda_name}_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags               = merge(var.global_tags, local.lambda_tags)
}

resource "aws_iam_policy" "curator" {
  name        = "${local.lambda_name}-policy"
  description = "${local.lambda_name}-policy"
  policy      = file("../files/IAM/curator_lambda.json")
}

resource "aws_iam_role_policy_attachment" "curator" {
  role       = aws_iam_role.curator.name
  policy_arn = aws_iam_policy.curator.arn
}


output "curator_lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.curator.arn
}

output "curator_lambda_function_invoke_arn" {
  description = "The Invoke ARN of the Lambda function"
  value       = aws_lambda_function.curator.invoke_arn
}

output "curator_lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.curator.function_name
}

output "curator_lambda_function_qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = aws_lambda_function.curator.qualified_arn
}

output "curator_lambda_role_arn" {
  description = "The ARN of the IAM role created for the Lambda function"
  value       = aws_iam_role.curator.arn
}

output "curator_lambda_role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = aws_iam_role.curator.name
}

output "curator_lambda__archive" {
  description = "Path to the archive file"
  value       = data.archive_file.lambda.output_path
}