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
 * - IAM Conditions
 *
 * ## Role formats
 *
 * - bigquery-dataset:[org|project|]-role:datasetId
 * - bigquery-table:[org|project|]-role:datasetId:tableId
 * - billing:role
 * - [org|project|]-role
 * - storage:[org|project|]-role:bucket
 *
 * ## Required Inputs
 *
 * organization_id or project_id MUST be specified
 *
 */

# TODO:
#   constraint patterns ?
#     secret prefix
#       expression  = "resource.name.startsWith(${format("\"%s/%s/%s/%s%s\"","projects",var.project_number,"secrets",each.value.secrets_prefix,"__")})"
#   google_cloud_run_service_iam_member
#   google_folder_iam_member
#   google_secret_manager_secret_iam_member - for single secret
#   google_service_account_iam_member - allow principal to impersonate service account
#   more as needed

# TODO: ?? update to be 1 of project, org, or billing required
resource "null_resource" "org_proj_precondition_validation" {
  lifecycle {
    precondition {
      condition     = (var.project_id != "" && var.organization_id == "") || (var.project_id == "" && var.organization_id != "")
      error_message = "Only organization_id or project_id can be specified and one must be specified."
    }
  }
}
locals {
  target_id = var.project_id != "" ? var.project_id : var.organization_id
  members = flatten([for member in var.members :
    [for role in member.roles :
  { member = member.member, role = role.role, condition = role.condition }]])
}

# Role format: bigquery-dataset:[org|project|]-<role>:datasetId
resource "google_bigquery_dataset_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.project_id != "" && startswith(member.role, "bigquery-dataset:") }

  dataset_id = split(":", each.value.role)[2]
  member     = each.value.member
  project    = local.target_id
  role = startswith(split(":", each.value.role)[1], "project:") ? "projects/${var.project_id}/roles/${substr(split(":", each.value.role)[1], 8, -1)}" : (
    startswith(split(":", each.value.role)[1], "org:") ?
    "organizations/${var.organization_id}/roles/${substr(split(":", each.value.role)[1], 4, -1)}"
  : "roles/${split(":", each.value.role)[1]}")
  dynamic "condition" {
    for_each = lookup(each.value, "condition", null) != null ? [each.value.condition] : []
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
  if var.project_id != "" && startswith(member.role, "bigquery-table:") }

  dataset_id = split(":", each.value.role)[2]
  member     = each.value.member
  project    = local.target_id
  role = startswith(split(":", each.value.role)[1], "project:") ? "projects/${var.project_id}/roles/${substr(split(":", each.value.role)[1], 8, -1)}" : (
    startswith(split(":", each.value.role)[1], "org:") ?
    "organizations/${var.organization_id}/roles/${substr(split(":", each.value.role)[1], 4, -1)}"
  : "roles/${split(":", each.value.role)[1]}")
  table_id = split(":", each.value.role)[3]
  dynamic "condition" {
    for_each = lookup(each.value, "condition", null) != null ? [each.value.condition] : []
    content {
      description = condition.value.description
      expression  = condition.value.expression
      title       = condition.value.title
    }
  }
}

# Role format: billing:<role>
resource "google_billing_account_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.billing_account_name != "" && startswith(member.role, "billing:") }

  billing_account_id = data.google_billing_account.self[0].id
  member             = each.value.member
  role               = "roles/${split(":", each.value.role)[1]}"
}

# Role format: [org|]-<role>
resource "google_organization_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.organization_id != "" && !contains(["bigquery-dataset", "bigquery-table", "storage"], element(split(":", member.role), 0)) }

  org_id = local.target_id
  role = (
    startswith(each.value.role, "org:") ?
    "organizations/${var.organization_id}/roles/${substr(each.value.role, 4, -1)}"
  : "roles/${each.value.role}")
  member = each.value.member
  dynamic "condition" {
    for_each = lookup(each.value, "condition", null) != null ? [each.value.condition] : []
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
  if var.project_id != "" && !contains(["bigquery-dataset", "bigquery-table", "storage"], element(split(":", member.role), 0)) }

  project = local.target_id
  role = startswith(each.value.role, "project:") ? "projects/${var.project_id}/roles/${substr(each.value.role, 8, -1)}" : (
    startswith(each.value.role, "org:") ?
    "organizations/${var.organization_id}/roles/${substr(each.value.role, 4, -1)}"
  : "roles/${each.value.role}")
  member = each.value.member
  dynamic "condition" {
    # NO - for_each = each.value.condition[*]
    # NO - for_each = each.value.condition != null ? [each.value.condition] : []
    # NO - for_each = { for condition in each.value.condition[*] : "${condition.title}-${condition.description}-${condition.expression}" => condition }
    for_each = lookup(each.value, "condition", null) != null ? [each.value.condition] : []
    content {
      description = condition.value.description
      expression  = condition.value.expression
      title       = condition.value.title
    }
  }
}

# TODO
# Role format: sa:[org|project|]-<role>:<serviceAccount>
#resource "google_service_account_iam_member" "self" {}

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
    for_each = lookup(each.value, "condition", null) != null ? [each.value.condition] : []
    content {
      description = condition.value.description
      expression  = condition.value.expression
      title       = condition.value.title
    }
  }
}
