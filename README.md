
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# terraform-google-iam-members

[![Releases](https://img.shields.io/github/v/release/notablehealth/terraform-google-iam-members)](https://github.com/notablehealth/terraform-google-iam-members/releases)

[Terraform Module Registry](https://registry.terraform.io/modules/notablehealth/iam-members/google)

Terraform module for Google IAM memberships

## Supports

- Google roles
- Project custom roles
- Organization custom roles
- Storage bucket roles
- BigQuery dataset roles
- BigQuery table roles
- IAM Conditions

## Role formats

- bigquery-dataset:[org|project|]-<role>:datasetId
- bigquery-table:[org|project|]-<role>:datasetId:tableId
- billing:<role>
- [org|project|]-<role>
- storage:[org|project|]-<role>:<bucket>

## Required Inputs

organization\_id or project\_id MUST be specified

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
    source = "notablehealth/<module-name>/google"
    # Recommend pinning every module to a specific version
    # version = "x.x.x"
    # Required variables
        members =
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.3 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_bigquery_dataset_iam_member.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_bigquery_table_iam_member.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table_iam_member) | resource |
| [google_billing_account_iam_member.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_account_iam_member) | resource |
| [google_organization_iam_member.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_member.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_storage_bucket_iam_member.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [null_resource.org_proj_precondition_validation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [google_billing_account.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/billing_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account_name"></a> [billing\_account\_name](#input\_billing\_account\_name) | Billing account name. | `string` | `""` | no |
| <a name="input_members"></a> [members](#input\_members) | List of members and roles to add them to. | <pre>list(object({<br>    member = string<br>    roles = list(object({<br>      role = string<br>      condition = optional(object({<br>        description = string<br>        expression  = string<br>        title       = string<br>      }))<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | Organization ID. | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID. | `string` | `""` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
