variable "name_prefix" {
  description = "String to prefix on object names"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "String to append to object names. This is optional, so start with dash if using"
  type        = string
  default     = ""
}

variable "unique_name" {
  description = "Unique string to describe resources. E.g. 'ebs-append' would make <prefix><name>(type)<suffix>"
  type        = string
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default = {
    Developer   = "StratusGrid"
    Provisioner = "Terraform"
  }
}

variable "sns_alarm_target" {
  description = "ARN for sns alarm to be targeted for performance alerts"
  type        = string
  default     = ""
}

variable "alarm_threshold_standard" {
  description = "Float value for alarm threshold to be used as lower limit for CPU Credit Balance on Standard Burst instances(e.g. 25.0)"
  type        = string
  default     = "25.0"
}

variable "alarm_threshold_unlimited" {
  description = "Float value for alarm threshold to be used as upper limit for CPU Surplus Credit Balance on Unlimited Burst instances (e.g. 1.0)"
  type        = string
  default     = "1.0"
}

variable "alarm_period" {
  description = "Number of seconds for period value of alarm (Less than 300 will result in 'insufficient data' unless you have detailed monitoring enabled!)"
  type        = string
  default     = "300"
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days for retention period of Lambda logs"
  type        = string
  default     = "30"
}

variable "lambda_tracing_option" {
  description = "Lambda Tracing option whether to sample and trace a subset of incoming requests with AWS X-Ray."
  type        = string
  default     = "Active"
}

variable "kms_log_key_deletion_window" {
  description = "Duration (in day) of kms key created, default is 30"
  type        = number
}
