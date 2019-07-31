# terraform-aws-lambda-event-handler-cpu-creditbalance
This module will deploy a lambda function which will listen for ec2 instance running/stopped/terminated events and put/delete CreditBalance alarms for cpu credits.

### Example Usage:
```
module "cpu_credit_balance_lambda" {
  source   = "StratusGrid/lambda-event-handler-cpu-creditbalance/aws"
  version  = "2.0.0"
  # source   = "github.com/StratusGrid/terraform-aws-lambda-event-handler-cpu-creditbalance"

  name_prefix      = var.name_prefix
  name_suffix      = local.name_suffix
  unique_name      = "event-handler-cpu-credit-balance"
  sns_alarm_target = aws_sns_topic.infrastructure_alerts.arn
  input_tags       = merge(local.common_tags, {})
}
```
