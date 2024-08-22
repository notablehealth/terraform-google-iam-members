
data "google_billing_account" "self" {
  count           = var.billing_account_name != "" ? 1 : 0
  display_name    = var.billing_account_name
  lookup_projects = false
  open            = true
}
