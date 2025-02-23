resource "github_actions_secret" "tfe_token" {
  secret_name     = "TFE_TOKEN"
  repository      = var.github_repository
  plaintext_value = tfe_team_token.token.token
}
