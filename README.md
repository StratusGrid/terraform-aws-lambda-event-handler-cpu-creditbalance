<!-- BEGIN_TF_DOCS -->
<p align="center">                                                                                                                                            
                                                                                
  <img src="https://github.com/StratusGrid/terraform-readme-template/blob/main/header/stratusgrid-logo-smaller.jpg?raw=true" />
  <p align="center">
    <a href="https://stratusgrid.com/book-a-consultation">Contact Us Test</a>
    <a href="https://stratusgrid.com/cloud-cost-optimization-dashboard">Stratusphere FinOps</a>
    <a href="https://stratusgrid.com">StratusGrid Home</a>
    <a href="https://stratusgrid.com/blog">Blog</a>
  </p>
</p>

# terraform-aws-lambda-event-handler-cpu-creditbalance

GitHub: [StratusGrid/terraform-aws-lambda-event-handler-cpu-creditbalance](https://github.com/StratusGrid/terraform-aws-lambda-event-handler-cpu-creditbalance)

This module will deploy a lambda function which will listen for ec2 instance running/stopped/terminated events and put/delete CreditBalance alarms for cpu credits. 

## Example:
```hcl
module "cpu_credit_balance_lambda" {
  source   = "StratusGrid/lambda-event-handler-cpu-creditbalance/aws"
  version  = "2.1.0"
  # source   = "github.com/StratusGrid/terraform-aws-lambda-event-handler-cpu-creditbalance"

  name_prefix      = var.name_prefix
  name_suffix      = local.name_suffix
  unique_name      = "event-handler-cpu-credit-balance"
  sns_alarm_target = aws_sns_topic.infrastructure_alerts.arn
  input_tags       = merge(local.common_tags, {})
}
```
---

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.function_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.function_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.function_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.function_policy_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.log_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_cloudwatch_event_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_period"></a> [alarm\_period](#input\_alarm\_period) | Number of seconds for period value of alarm (Less than 300 will result in 'insufficient data' unless you have detailed monitoring enabled!) | `string` | `"300"` | no |
| <a name="input_alarm_threshold_standard"></a> [alarm\_threshold\_standard](#input\_alarm\_threshold\_standard) | Float value for alarm threshold to be used as lower limit for CPU Credit Balance on Standard Burst instances(e.g. 25.0) | `string` | `"25.0"` | no |
| <a name="input_alarm_threshold_unlimited"></a> [alarm\_threshold\_unlimited](#input\_alarm\_threshold\_unlimited) | Float value for alarm threshold to be used as upper limit for CPU Surplus Credit Balance on Unlimited Burst instances (e.g. 1.0) | `string` | `"1.0"` | no |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | Number of days for retention period of Lambda logs | `string` | `"30"` | no |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to resources | `map(string)` | <pre>{<br>  "Developer": "StratusGrid",<br>  "Provisioner": "Terraform"<br>}</pre> | no |
| <a name="input_kms_log_key_deletion_window"></a> [kms\_log\_key\_deletion\_window](#input\_kms\_log\_key\_deletion\_window) | Duration (in day) of kms key created, default is 30 | `number` | n/a | yes |
| <a name="input_lambda_tracing_option"></a> [lambda\_tracing\_option](#input\_lambda\_tracing\_option) | Lambda Tracing option whether to sample and trace a subset of incoming requests with AWS X-Ray. | `string` | `"Active"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | String to prefix on object names | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | String to append to object names. This is optional, so start with dash if using | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the region where the logs are stored | `string` | `"us-east-1"` | no |
| <a name="input_sns_alarm_target"></a> [sns\_alarm\_target](#input\_sns\_alarm\_target) | ARN for sns alarm to be targeted for performance alerts | `string` | `""` | no |
| <a name="input_unique_name"></a> [unique\_name](#input\_unique\_name) | Unique string to describe resources. E.g. 'ebs-append' would make <prefix><name>(type)<suffix> | `string` | n/a | yes |

## Outputs

No outputs.

---

<span style="color:red">Note:</span> Manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml .`
<!-- END_TF_DOCS -->