locals {
  acme_server = var.acme_production ? "" : "https://acme-staging-v02.api.letsencrypt.org/directory"
  # TODO add production server url
}
