#!/bin/bash -x

PROJECT_ID=test-project-373118
GITHUB_ORG=melanmeg
WORKLOAD_IDENTITY_POOL_ID=projects/593997455442/locations/global/workloadIdentityPools/github
REPO=melanmeg/test2-workload-identity

# gcloud iam workload-identity-pools create "github" \
#   --project="${PROJECT_ID}" \
#   --location="global" \
#   --display-name="GitHub Actions Pool"

# gcloud iam workload-identity-pools describe "github" \
#   --project="${PROJECT_ID}" \
#   --location="global" \
#   --format="value(name)"
# # projects/593997455442/locations/global/workloadIdentityPools/github

# gcloud iam workload-identity-pools providers create-oidc "my-repo" \
#   --project="${PROJECT_ID}" \
#   --location="global" \
#   --workload-identity-pool="github" \
#   --display-name="My GitHub repo Provider" \
#   --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
#   --attribute-condition="assertion.repository_owner == '${GITHUB_ORG}'" \
#   --issuer-uri="https://token.actions.githubusercontent.com"

# gcloud iam workload-identity-pools providers describe "my-repo" \
#   --project="${PROJECT_ID}" \
#   --location="global" \
#   --workload-identity-pool="github" \
#   --format="value(name)"
# # projects/593997455442/locations/global/workloadIdentityPools/github/providers/my-repo

# gcloud secrets add-iam-policy-binding "my-secret" \
#   --project="${PROJECT_ID}" \
#   --role="roles/secretmanager.secretAccessor" \
#   --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"

# gcloud artifacts repositories add-iam-policy-binding "my-repo" \
#   --project="${PROJECT_ID}" \
#   --role="roles/artifactregistry.admin" \
#   --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"

# gcloud artifacts repositories add-iam-policy-binding my-repo \
# --location=us-central1 --member=allUsers --role=roles/artifactregistry.reader [4]

gcloud artifacts repositories add-iam-policy-binding "my-repo" \
  --location="asia-northeast1" \
  --role="roles/artifactregistry.writer" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"
