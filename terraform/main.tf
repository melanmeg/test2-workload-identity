locals {
  region              = "asia-northeast1"
  zones               = ["asia-northeast1-a"]
  project_id          = "test-project-373118"
  github_repository   = "melanmeg/test2-workload-identity"

  workload_identity_pool_id          = "my-github-pool6"
  workload_identity_pool_provider_id = "my-github-pool-provider6"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.1.0"
    }
  }
}

provider "google" {
  project        = local.project_id
  region         = local.region
  zone           = local.zones[0]
}

resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = local.project_id
  workload_identity_pool_id = local.workload_identity_pool_id
}

resource "google_iam_workload_identity_pool_provider" "github_pool_provider" {
  project                            = local.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = local.workload_identity_pool_provider_id
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  attribute_condition = "assertion.repository == '${local.github_repository}'"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_artifact_registry_repository" "repository" {
  location      = local.region
  repository_id = "my-repository"
  format        = "DOCKER"
}
