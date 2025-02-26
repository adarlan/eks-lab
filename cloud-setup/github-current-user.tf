data "github_user" "current" {
  username = ""
}

locals {
  github_owner = data.github_user.current.login
}
