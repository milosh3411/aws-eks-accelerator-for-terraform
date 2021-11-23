/*** Default Tags ***/
variable "tag_buc" {
  description = "The Business Unit Code associated with the group responsible for the deployed asset."
  default     = "4010.523420.0000..0000.0000.0000"
}
variable "tag_support_group" {
  description = "The name of the group responsible for the deployed asset."
  default     = "Ambit Operations"
}
variable "tag_app_group_email" {
  description = "The email address for the operations team responsible for the deployed asset."
  default     = "Ambit.Ops.Support@fisglobal.com"
}

variable "tag_environment_type" {
  description = "The tier of environment for the application -- this is separate from the service level defined at the subscription level."
  default     = "Dev"
}

variable "tag_customer_crmid" {
  description = "The end customer of the system and the CRM ID of the end customer of the system."
  default     = ""
}

/*** EC2 tags     ***/
variable "tag_expiration_date" {
  default = "Never"
}

variable "tag_solution_central_id" {
  default = "15589"
}

variable "tag_sla" {
  default = "99.5"
}

variable "tag_maintenance_window" {
  default = ["*/*/*/*/0"]
}

variable "tag_tier" {
  default = "System"
}

variable "tag_on_hours" {
  default = "Always"
}