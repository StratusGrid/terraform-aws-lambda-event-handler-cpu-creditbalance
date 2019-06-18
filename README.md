# terraform-aws-lambda-event-handler-ebs-burstbalance
This module will deploy a lambda function which will listen for ebs volume creation/deletion events and put/delete BurstBalance alarms for gp2 volumes.

### Example Usage:
```
module "ebs-burst-balance-lambda" {
  source = "StratusGrid/lambda-event-handler-ebs-burstbalance/aws"
  version = "1.0.3"
  name_prefix = "${var.name_prefix}"
  unique_name = "event-handler-ebs-burst-balance"
  sns_alarm_target = "${var.sns_alarm_target}"
}
```
