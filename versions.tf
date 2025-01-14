
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.3"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
