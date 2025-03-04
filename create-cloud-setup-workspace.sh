#!/bin/bash
set -e
cd $(dirname $0)

gh_repo_name=$(gh repo view --json name -q '.name')
tf_organization=$(sed -n "s/^[[:space:]]*hcp_terraform_organization[[:space:]]*=[[:space:]]*\"\(.*\)\".*/\1/p" cloud-setup/terraform.tfvars)
tf_workspace="$gh_repo_name-cloud-setup"
tf_version=$(sed -n "s/^[[:space:]]*required_version[[:space:]]*=[[:space:]]*\"\(.*\)\".*/\1/p" cloud-setup/terraform.tf)
tf_token=$(jq -r '.credentials."app.terraform.io".token' ~/.terraform.d/credentials.tfrc.json)

response=$(curl -s -o /dev/null -w "%{http_code}" \
    --header "Authorization: Bearer $tf_token" \
    --header "Content-Type: application/vnd.api+json" \
    "https://app.terraform.io/api/v2/organizations/${tf_organization}/workspaces/${tf_workspace}"
)

if [[ "$response" == "200" ]]; then
    echo "HCP Terraform workspace '$tf_workspace' already exists."
elif [[ "$response" == "404" ]]; then
    echo "HCP Terraform workspace '$tf_workspace' does not exist. Creating..."
    curl -s --request POST \
        --header "Authorization: Bearer $tf_token" \
        --header "Content-Type: application/vnd.api+json" \
        --data "{
            \"data\": {
                \"attributes\": {
                    \"name\": \"$tf_workspace\",
                    \"terraform-version\": \"$tf_version\",
                    \"execution-mode\": \"local\"
                },
                \"type\": \"workspaces\"
            }
        }" "https://app.terraform.io/api/v2/organizations/$tf_organization/workspaces"
else
    echo "Error fetching HCP Terraform workspace '$tf_workspace'"
    echo "Response status code: $response"
    exit 1
fi
