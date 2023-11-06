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
 */



# TODO:
#   Add contraint support
#   Add bigquery dataset support  bigquery-dataset:project-<role>:datasetId             resource "google_bigquery_dataset_iam_member" "self"
#   Add bigquery table support    bigquery-table:project-<role>:datasetId.tableId       resource "google_bigquery_table_iam_member" "self"    ???
#   Add billing account support   billing:organization-<role>:billingAccountId
#   Turn into module (use by this and service-accounts) - Process a single member. Call to module can do the for_each (any difference??)
#   role split on : [1] in or not in set of permission types
#      if contains(["project", "org", "storage"], split(":", each.value.role)[1])

locals {
  target_id = var.project_id != "" ? var.project_id : var.organization_id
}
# tf v1.5 add validation for id, one and only 1 is not ""

locals {
  members = flatten([for member in var.members :
    [for role in member.roles :
  { member = member.member, role = role }]])
}

# Role format: bigquery-dataset:project-<role>:datasetId
resource "google_bigquery_dataset_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.project_id != "" && contains(["bigquery-dataset"], split(":", member.role)[1]) }

  dataset_id = split(":", each.value.role)[3]
  member     = each.value.member
  project    = local.target_id
  # Handle custom org/project roles, pre-defined
  role = split(":", each.value.role)[2] # ??
  #condition {}
}
# Role format: bigquery-table:project-<role>:datasetId:tableId
resource "google_bigquery_table_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.project_id != "" && contains(["bigquery-table"], split(":", member.role)[1]) }

  dataset_id = split(":", each.value.role)[3]
  member     = each.value.member
  project    = local.target_id
  # Handle custom org/project roles, pre-defined
  role     = ""
  table_id = split(":", each.value.role)[4]
  #condition {}
}
#   Add billing account support   billing:organization-<role>:billingAccountId

# Role format: [org|]-<role>
resource "google_organization_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.organization_id != "" && !startswith(member.role, "storage:") }

  org_id = local.target_id
  role = (
    startswith(each.value.role, "org:") ?
    "organizations/${var.organization_id}/roles/${substr(each.value.role, 4, -1)}"
  : "roles/${each.value.role}")
  member = each.value.member
}

# Role format: [project|org|]-<role>
resource "google_project_iam_member" "self" {
  for_each = { for member in local.members : "${member.member}-${member.role}" => member
  if var.project_id != "" && !startswith(member.role, "storage:") }

  project = local.target_id
  role = startswith(each.value.role, "project:") ? "projects/${var.project_id}/roles/${substr(each.value.role, 8, -1)}" : (
    startswith(each.value.role, "org:") ?
    "organizations/${var.organization_id}/roles/${substr(each.value.role, 4, -1)}"
  : "roles/${each.value.role}")
  member = each.value.member
}

# Role format: storage:[project|org|]-<role>:<bucket>
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
}
