
module "iam-members" {
  source = "../.."

  members    = var.members
  project_id = var.project_id
}
