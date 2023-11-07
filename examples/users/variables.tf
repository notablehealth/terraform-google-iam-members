
variable "project_id" {
  description = "Project ID."
  type        = string
  default     = ""
}

variable "members" {
  description = "List of members and roles to add them to."
  type = list(object({
    member = string
    roles  = list(string)
    condition = optional(object({
      description = string
      expression  = string
      title       = string
    }))
  }))
}
