
variable "billing_account_name" {
  description = "Billing account name."
  type        = string
  default     = ""
}
variable "organization_id" {
  description = "Organization ID."
  type        = string
  default     = ""
}
variable "project_id" {
  description = "Project ID."
  type        = string
  default     = ""
}

# Allow global condition for all member roles
#  TODO: add code to handle new data
variable "members" {
  description = "List of members and roles to add them to."
  type = list(object({
    member = string
    #condition = optional(object({
    #  description = string
    #  expression  = string
    #  title       = string
    #}))
    roles = list(object({
      role = string
      condition = optional(object({
        description = string
        expression  = string
        title       = string
      }))
    }))
  }))
}
