# Workload Identity Federation für GitHub Actions

resource "azurerm_user_assigned_identity" "github" {
  name                = "id-${var.prefix}-github"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
}

# Azure vergleicht das "subject" im GitHub-Token exakt (keine Wildcards).
# GitHub setzt je nach Job ein anderes Subject, daher zwei Credentials:
#   - plan:  Job ohne Environment  -> repo:<repo>:ref:refs/heads/main
#   - apply: Job im Environment    -> repo:<repo>:environment:dev
# Das Environment "dev" ist das Approval Gate (Required reviewers) für apply.
#
# GitHub nutzt im Subject die unveränderlichen IDs: owner@<id>/repo@<id>.
# Schützt davor, dass ein später gleichnamig angelegtes Repo Tokens erhält.
locals {
  github_owner = split("/", var.github_repository)[0]
  github_repo  = split("/", var.github_repository)[1]

  # z.B. repo:faakkoc@79111854/pd-az-task@1407965189
  github_subject_prefix = "repo:${local.github_owner}@${var.github_owner_id}/${local.github_repo}@${var.github_repository_id}"
}

# Plan-Job (Push auf main + nächtlicher Drift-Check)
resource "azurerm_federated_identity_credential" "github_plan" {
  name                      = "github-plan"
  user_assigned_identity_id = azurerm_user_assigned_identity.github.id
  issuer                    = "https://token.actions.githubusercontent.com"
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = "${local.github_subject_prefix}:ref:refs/heads/main"
}

# Apply-Job (läuft erst nach manueller Freigabe im Environment "dev")
resource "azurerm_federated_identity_credential" "github_apply" {
  name                      = "github-apply"
  user_assigned_identity_id = azurerm_user_assigned_identity.github.id
  issuer                    = "https://token.actions.githubusercontent.com"
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = "${local.github_subject_prefix}:environment:dev"
}
