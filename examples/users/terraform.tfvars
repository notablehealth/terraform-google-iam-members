
project_id = "notable-terraform-testing"
members = [
  { # Project viewer
    member = "user:abc@example.org",
    roles = [{
      role = "viewer"
    }],
  },
  { # Project owner with restriction
    member = "user:abc@example.org",
    roles = [{
      role = "owner"
      condition = {
        description = "Restrict "
        expression  = ""
        title       = "Restrict "
      }
    }],
  },
  { # Bigquery DataSet # DataSetId project.name
    member = "user:abc1@example.org",
    roles  = [{ role = "bigquery-dataset:bigquery.dataViewer:datasetId" }],
  },
  { # Bigtable
    member = "user:abc2@example.org",
    roles  = [{ role = "bigquery-table:bigquery.dataViewer:datasetId:tableId" }],
  },
  { # Storage
    member = "user:abc3@example.org",
    roles = [{
      role = "storage:storage.objectViewer:notable-terraform-testing-bucket"
      condition = {
        description = "Restrict to prefix"
        expression  = "resource.name.startsWith(“projects/_/buckets/notable-terraform-testing-bucket/objects/folder-a”)"
        title       = "Restrict to prefix"
      }
    }],
  }
]


# resource.name.startsWith(\"projects/$PROJECT_ID/buckets/$SHARED_BUCKET/objects/folder-xx\")
# resource.name.startsWith(\“projects/_/buckets/notable-terraform-testing-bucket/objects/folder-a\”)
