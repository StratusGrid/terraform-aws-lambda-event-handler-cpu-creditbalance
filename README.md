# terraform-aws-lambda-event-handler-cpu-creditbalance
This module will deploy a lambda function which will listen for ec2 instance running/stopped/terminated events and put/delete CreditBalance alarms for cpu credits.

### Example Usage:
```
module "cpu-credit-balance-lambda" {
  source = "StratusGrid/lambda-event-handler-cpu-creditbalance/aws"
  version = "1.0.4"
  name_prefix = "${var.name_prefix}"
  unique_name = "event-handler-cpu-credit-balance"
  sns_alarm_target = "${var.sns_alarm_target}"
}
```
