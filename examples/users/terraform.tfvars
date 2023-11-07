
project_id = "notable-terraform-testing"
members = [
  {
    roles  = ["viewer"],
    member = "user:abc@example.org",
    #condition = {
    #  description = "Restrict "
    #  expression  = ""
    #  title       = "Restrict "
    #}
  },
  { # Bigquery DataSet # DataSetId project.name
    roles  = ["bigquery-dataset:bigquery.dataViewer:datasetId"],
    member = "user:abc1@example.org",
    #condition = {
    #  description = "Restrict "
    #  expression  = ""
    #  title       = "Restrict "
    #}
  },
  { # Bigtable
    roles  = ["bigquery-table:bigquery.dataViewer:datasetId:tableId"],
    member = "user:abc2@example.org",
    #condition = {
    #  description = "Restrict "
    #  expression  = ""
    #  title       = "Restrict "
    #}
  },
  { # Storage
    roles  = ["storage:storage.objectViewer:notable-terraform-testing-bucket"],
    member = "user:abc3@example.org",
    condition = {
      description = "Restrict to prefix"
      expression  = "resource.name.startsWith(“projects/_/buckets/notable-terraform-testing-bucket/objects/folder-a”)"
      title       = "Restrict to prefix"
    }
  }
]


# resource.name.startsWith(\"projects/$PROJECT_ID/buckets/$SHARED_BUCKET/objects/folder-xx\")
# resource.name.startsWith(\“projects/_/buckets/notable-terraform-testing-bucket/objects/folder-a\”)
