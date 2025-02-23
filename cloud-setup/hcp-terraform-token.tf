data "tfe_team" "team" {
  name         = var.team
  organization = var.organization
}

resource "tfe_team_token" "token" {
  team_id = data.tfe_team.team.id
}

# TODO create a team that can manage only the workspaces on this project
