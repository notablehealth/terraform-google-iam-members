/**
 * # terraform-google-iam-members
 *
 * [![Releases](https://img.shields.io/github/v/release/notablehealth/terraform-google-iam-members)](https://github.com/notablehealth/terraform-google-iam-members/releases)
 *
 * [Terraform Module Registry](https://registry.terraform.io/modules/notablehealth/iam-members/google)
 *
 * Terraform module for Google IAM memberships
 *
 * ## Supports
 *
 * - Google roles
 * - Project custom roles
 * - Organization custom roles
 * - Storage bucket roles
 * - BigQuery dataset roles
 * - BigQuery table roles
 *
 * ## Role formats
 *
 * - bigquery-dataset:[org|project|]-<role>:datasetId
 * - bigquery-table:[org|project|]-<role>:datasetId:tableId
 * - [org|project|]-<role>
 * - storage:[org|project|]-<role>:<bucket>
 *
 */

# TODO:
#   Add contraint support
#   Add billing account support   billing:organization-<role>:billingAccountId
#   Turn into module (use by this and service-accounts) - Process a single member. Call to module can do the for_each (any difference??)
#   role split on : [1] in or not in set of permission types
#      if contains(["project", "org", "storage"], split(":", each.value.role)[1])

resource "null_resource" "org_proj_precondition_validation" {
  lifecycle {
    precondition {
      condition     = (var.project_id != "" && var.organization_id == "") || (var.project_id == "" && var.organization_id != "")
      error_message = "Only organization_id or project_id can be specified."
    }
  }
}
locals {
  target_id = var.project_id != "" ? var.project_id : var.organization_id
}

locals {
  members = flatten([for member in var.members :
    [for role in member.roles :
  { member = member.member, role = role }]])
}

# Role format: bigquery-dataset:[org|project|]-<role>:datasetId
resource "google_bigquery_dataset_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.project_id != "" && contains(["bigquery-dataset"], split(":", member.role)[1]) }

  dataset_id = split(":", each.value.role)[3]
  member     = each.value.member
  project    = local.target_id
  role = startswith(split(":", each.value.role)[2], "project:") ? "projects/${var.project_id}/roles/${substr(split(":", each.value.role)[2], 8, -1)}" : (
    startswith(split(":", each.value.role)[2], "org:") ?
    "organizations/${var.organization_id}/roles/${substr(split(":", each.value.role)[2], 4, -1)}"
  : "roles/${split(":", each.value.role)[2]}")
  dynamic "condition" {
    for_each = each.value.condition[*]
    #for_each = { for condition in each.value.condition[*]: "title+description+expression" => condition }
    #for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      description = condition.value.description
      expression  = condition.value.expression
      title       = condition.value.title
    }
  }
}

# Role format: bigquery-table:[org|project|]-<role>:datasetId:tableId
resource "google_bigquery_table_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.project_id != "" && contains(["bigquery-table"], split(":", member.role)[1]) }

  dataset_id = split(":", each.value.role)[3]
  member     = each.value.member
  project    = local.target_id
  role = startswith(split(":", each.value.role)[2], "project:") ? "projects/${var.project_id}/roles/${substr(split(":", each.value.role)[2], 8, -1)}" : (
    startswith(split(":", each.value.role)[2], "org:") ?
    "organizations/${var.organization_id}/roles/${substr(split(":", each.value.role)[2], 4, -1)}"
  : "roles/${split(":", each.value.role)[2]}")
  table_id = split(":", each.value.role)[4]
  dynamic "condition" {
    for_each = each.value.condition[*]
    content {
      description = condition.value.description
      expression  = condition.value.expression
      title       = condition.value.title
    }
  }
}
#   Add billing account support   billing:organization-<role>:billingAccountId

# Role format: [org|]-<role>
resource "google_organization_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.organization_id != "" && !contains(["bigquery-dataset", "bigquery-table", "storage"], split(":", member.role)[1]) }

  org_id = local.target_id
  role = (
    startswith(each.value.role, "org:") ?
    "organizations/${var.organization_id}/roles/${substr(each.value.role, 4, -1)}"
  : "roles/${each.value.role}")
  member = each.value.member
  dynamic "condition" {
    for_each = each.value.condition[*]
    content {
      description = condition.value.description
      expression  = condition.value.expression
      title       = condition.value.title
    }
  }
}

# Role format: [org|project|]-<role>
resource "google_project_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.project_id != "" && !contains(["bigquery-dataset", "bigquery-table", "storage"], split(":", member.role)[1]) }

  project = local.target_id
  role = startswith(each.value.role, "project:") ? "projects/${var.project_id}/roles/${substr(each.value.role, 8, -1)}" : (
    startswith(each.value.role, "org:") ?
    "organizations/${var.organization_id}/roles/${substr(each.value.role, 4, -1)}"
  : "roles/${each.value.role}")
  member = each.value.member
  dynamic "condition" {
    for_each = each.value.condition[*]
    content {
      description = condition.value.description
      expression  = condition.value.expression
      title       = condition.value.title
    }
  }
}

# Role format: storage:[org|project|]-<role>:<bucket>
resource "google_storage_bucket_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.project_id != "" && startswith(member.role, "storage:") }

  bucket = one(flatten(regexall("[^:]+:[^:]+:(.*)", each.value.role)))
  member = each.value.member
  # Role format: storage:(project|org|)-<role>:<bucket>
  role = startswith(each.value.role, "storage:project-") ? "projects/${var.project_id}/roles/${one(flatten(regexall("[^:]+:([^:]+):", each.value.role)))}" : (
    startswith(each.value.role, "storage:org-") ?
    "organizations/${var.organization_id}/roles/${one(flatten(regexall("[^:]+:([^:]+):", each.value.role)))}"
  : "roles/${one(flatten(regexall("[^:]+:([^:]+):", each.value.role)))}")
  dynamic "condition" {
    for_each = each.value.condition[*]
    content {
      description = condition.value.description
      expression  = condition.value.expression
      title       = condition.value.title
    }
  }
}
