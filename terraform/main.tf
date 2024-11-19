locals {
  region              = "asia-northeast1"
  zones               = ["asia-northeast1-a"]
  project_id          = "test-project-373118"
  github_repository   = "melanmeg/test2-workload-identity"

  workload_identity_pool_id          = "my-github-pool7"
  workload_identity_pool_provider_id = "my-github-pool-provider7"
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

resource "google_artifact_registry_repository" "my_repo" {
  location      = local.region
  repository_id = "my-repository"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "my_repo_editor" {
  repository = google_artifact_registry_repository.my_repo.name
  location   = google_artifact_registry_repository.my_repo.location
  role       = "roles/artifactregistry.writer"
  member     = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${local.github_repository}"
}

# resource "google_service_account" "github_service_account" {
#   project      = local.project_id
#   account_id   = "my-github-sa"
# }

# resource "google_service_account_iam_member" "github_workload_identity_user" {
#   service_account_id = google_service_account.github_service_account.id
#   role               = "roles/iam.workloadIdentityUser"
#   member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${local.github_repository}"
#   depends_on         = [google_service_account.github_service_account]
# }

# resource "google_project_iam_member" "artifact_registry_reader" {
#   project = local.project_id
#   role    = "roles/artifactregistry.reader"
#   member  = google_service_account.github_service_account.member
# }

# resource "google_project_iam_member" "artifact_registry_writer" {
#   project = local.project_id
#   role    = "roles/artifactregistry.writer"
#   member  = google_service_account.github_service_account.member
# }
