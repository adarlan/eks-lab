#!/bin/bash
set -e
cd $(dirname $0)

./terraform-wrapper.sh argo-cd --init >/dev/null
source argo-cd/terraform.env
value=$(terraform -chdir=argo-cd output -json argocd_admin_credentials)
echo "$value" | jq -r '.'
