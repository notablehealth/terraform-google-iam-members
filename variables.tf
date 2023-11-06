
variable "organization_id" {
  description = "Organization ID."
  type        = string
  default     = ""
}
variable "project_id" {
  description = "Project ID."
  type        = string
}

variable "members" {
  description = "List of members and roles to add them to."
  type = list(object({
    member = string
    roles  = list(string)
  }))
}
