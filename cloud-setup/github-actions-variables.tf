resource "github_actions_variable" "name" {
  variable_name = "TERRAFORM_CONFIG_ENV"
  repository    = var.github_repository
  value         = var.terraform_config_env
}
