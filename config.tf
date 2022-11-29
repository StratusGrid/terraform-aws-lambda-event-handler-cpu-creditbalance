#Event rule to direct events to the Lambda Function

resource "aws_cloudwatch_event_rule" "event" {
  name        = "${var.name_prefix}-${var.unique_name}-rule${var.name_suffix}"
  description = "Pattern of events to forward to targets"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "running",
      "stopped",
      "terminated"
    ]
  }
}
PATTERN

}

#Target to direct event at function
resource "aws_cloudwatch_event_target" "function_target" {
  rule      = aws_cloudwatch_event_rule.event.name
  target_id = "${var.name_prefix}-${var.unique_name}-target${var.name_suffix}"
  arn       = aws_lambda_function.function.arn
}

#Permission to allow event trigger
resource "aws_lambda_permission" "allow_cloudwatch_event_trigger" {
  statement_id  = "TrustCWEToInvokeMyLambdaFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event.arn
}

#Automatic packaging of code
data "archive_file" "function_code" {
  type        = "zip"
  source_dir  = "${path.module}/function_code"
  output_path = "${path.module}/function_code_zipped/function_code.zip"
}

#Function to process event
resource "aws_lambda_function" "function" {
  filename         = data.archive_file.function_code.output_path
  source_code_hash = filebase64sha256(data.archive_file.function_code.output_path)
  function_name    = "${var.name_prefix}-${var.unique_name}-function${var.name_suffix}"
  role             = aws_iam_role.function_role.arn
  handler          = "main.handler"
  runtime          = "python3.9"
  timeout          = "10"

  tracing_config {
    mode = var.lambda_tracing_option
  }

  environment {
    variables = {
      sns_alarm_target          = var.sns_alarm_target
      alarm_threshold_standard  = var.alarm_threshold_standard
      alarm_threshold_unlimited = var.alarm_threshold_unlimited
      alarm_period              = var.alarm_period
    }
  }

  lifecycle {
    ignore_changes = [last_modified]
  }

  tags = local.common_tags
}

#Role to attach policy to Function
resource "aws_iam_role" "function_role" {
  name = "${var.name_prefix}-${var.unique_name}-role${var.name_suffix}"
  tags = local.common_tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

#Default policy for Lambda to be executed and put logs in Cloudwatch
resource "aws_iam_role_policy" "function_policy_default" {
  name = "${var.name_prefix}-${var.unique_name}-policy-default${var.name_suffix}"
  role = aws_iam_role.function_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowListCloudWatchLogGroups",
      "Effect": "Allow",
      "Action": "logs:DescribeLogStreams",
      "Resource": "${aws_cloudwatch_log_group.log_group.arn}:*"
    },
    {
      "Sid": "AllowCreatePutLogGroupsStreams",
      "Effect": "Allow",
      "Action": [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
      ],
      "Resource": [
          "${aws_cloudwatch_log_group.log_group.arn},
          "${aws_cloudwatch_log_group.log_group.arn}:log-stream:*"
      ]
    }
  ]
}
EOF

}

#Policy for additional Permissions for Lambda Execution
#tfsec:ignore:aws-iam-no-policy-wildcards -- Ignores warning on usage of Wildcards as changing them will require a refactor of the policy. An issue has been raised for this.
resource "aws_iam_role_policy" "function_policy" {
  name = "${var.name_prefix}-${var.unique_name}-policy${var.name_suffix}"
  role = aws_iam_role.function_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudwatchActions",
      "Effect": "Allow",
      "Action": [
          "cloudwatch:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowEc2Actions",
      "Effect": "Allow",
      "Action": [
          "ec2:DescribeInstance*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

#Cloudwatch Log Group for Function
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/lambda/${aws_lambda_function.function.function_name}"

  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = aws_kms_key.log_key.arn

  tags = local.common_tags
}

# CloudWatch Logs encryption key
resource "aws_kms_key" "log_key" {
  description             = "KMS key for encryption of cloudwatch logs generated by lambda trigger"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_log_key_deletion_window
  policy                  = data.aws_iam_policy_document.cloudwatch_kms.json
}

data "aws_iam_policy_document" "cloudwatch_kms" {
  statement {
    actions = [
      "kms:*",
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
      type = "AWS"
    }
    resources = [
      "*",
    ]
    sid = "Enable IAM User Permissions"
  }

  statement {
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    condition {
      test = "ArnEquals"
      values = [
        "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*",
      ]
      variable = "kms:EncryptionContext:aws:logs:arn"
    }
    principals {
      identifiers = [
        "logs.${var.region}.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      "*",
    ]
    sid = "Allow cloudwatch to encrypt logs"
  }
}