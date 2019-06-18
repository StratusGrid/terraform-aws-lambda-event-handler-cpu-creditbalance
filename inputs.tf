variable "name_prefix" {
  description = "String to prefix on object names"
  type = "string"
  default = ""
}

variable "name_suffix" {
  description = "String to append to object names. This is optional, so start with dash if using"
  type = "string"
  default = ""
}

variable "unique_name" {
  description = "Unique string to describe resources. E.g. 'ebs-append' would make <prefix><name>(type)<suffix>"
  type = "string"
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type = "map"
  default = {
    Developer   = "StratusGrid"
    Provisioner = "Terraform"
  }
}

variable "sns_alarm_target" {
  description = "ARN for sns alarm to be targeted for performance alerts"
  type = "string"
  default = ""
}

variable "alarm_threshold" {
  description = "Float value for alarm threshold (e.g. 75.0)"
  type = "string"
  default = "25.0"
}

variable "alarm_period" {
  description = "Number of seconds for period value of alarm (Less than 300 will result in 'insufficient data' unless you have detailed monitoring enabled!)"
  type = "string"
  default = "300"
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days for retention period of Lambda logs"
  type = "string"
  default = "30"
}
