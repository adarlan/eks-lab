#!/bin/bash
set -e

cd $(dirname $0)

reset=false
if [[ "$*" == *"--reset"* ]]; then
    reset=true
fi

main() {
    echo; echo "Reading configuration parameters"
    [ -f .env ] && source .env || touch .env
    # TODO instead of using the existing file, always download it with 'gh variable get'

    read_config_param    platform_name     'echo "demo"'
    read_config_param    github_user       'gh api user | jq -r .login'
    read_config_param    random_string     'tr -dc "a-z0-9" </dev/urandom | head -c 6'
    read_config_param    aws_cli_profile   'echo "default"'
    read_config_param    aws_account_alias 'aws --profile=$aws_cli_profile iam list-account-aliases --output text --query "AccountAliases[0]"'
    read_config_param    aws_account_id    'aws --profile=$aws_cli_profile sts get-caller-identity --query "Account" --output text'
    read_config_param    aws_iam_user      'aws --profile=$aws_cli_profile iam get-user --query "User.UserName" --output text'
    read_config_param    aws_region        'aws --profile=$aws_cli_profile configure get region'
    read_config_param    registered_domain 'echo "example.com"'
    read_config_param    base_host         'echo "$platform_name.$registered_domain"'
    read_config_param    email             'gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /user/public_emails | jq -r .[0].email'

    PLACEHOLDERS_JSON="{
    \"__PLATFORM_NAME__\":                       \"$platform_name\",
    \"__GITHUB_USER__\":                         \"$github_user\",
    \"__GITHUB_OWNER__\":                        \"$github_user\",
    \"__AWS_CLI_PROFILE__\":                     \"$aws_cli_profile\",
    \"__AWS_ACCOUNT_ID__\":                      \"$aws_account_id\",
    \"__AWS_ACCOUNT_ALIAS__\":                   \"$aws_account_alias\",
    \"__AWS_REGION__\":                          \"$aws_region\",
    \"__AWS_IAM_USER__\":                        \"$aws_iam_user\",
    \"__TERRAFORM_BACKEND_S3_BUCKET__\":         \"$platform_name-terraform-backend-$random_string\",
    \"__TERRAFORM_BACKEND_S3_DYNAMODB_TABLE__\": \"$platform_name-terraform-state-lock\",
    \"__TERRAFORM_BACKEND_S3_REGION__\":         \"$aws_region\",
    \"__DOMAIN_NAME__\":                         \"$registered_domain\",
    \"__BASE_HOST__\":                           \"$base_host\",
    \"__ACME_EMAIL__\":                          \"$email\",
    \"__RANDOM_STRING__\":                       \"$random_string\",
    \"__DOT__\":                                 \".\"
    }"

    echo "$PLACEHOLDERS_JSON" | jq

    repo_name=eks-lab
    # TODO get repo name from git remote

    gh variable set PLACEHOLDERS_JSON --body "$PLACEHOLDERS_JSON" --repo $github_user/$repo_name

    # Create AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY secrets
    AWS_ACCESS_KEY_ID=$(aws --profile=$aws_cli_profile configure get aws_access_key_id)
    AWS_SECRET_ACCESS_KEY=$(aws --profile=$aws_cli_profile configure get aws_secret_access_key)
    gh secret set AWS_ACCESS_KEY_ID --body "$AWS_ACCESS_KEY_ID" --repo $github_user/$repo_name
    gh secret set AWS_SECRET_ACCESS_KEY --body "$AWS_SECRET_ACCESS_KEY" --repo $github_user/$repo_name
}

read_config_param() {

    config_param="$1"
    default_value_cmd="$2"

    # Use current value as default (if current value is set)
    if [ "${!config_param}" != "" ]; then
        default_value="${!config_param}"
    elif ! default_value="$(eval $default_value_cmd)"; then
        exit 1
    fi

    if $reset || [ "${!config_param}" = "" ]; then
        read -p "- $config_param ($default_value): " "$config_param"
        if [ "${!config_param}" = "" ]; then
            eval "$config_param=\"$default_value\""
        fi
    else
        eval "$config_param=\"$default_value\""
        echo "- $config_param: ${!config_param}"
    fi

    # update config file
    if grep -q "^${config_param}=" .env > /dev/null; then
        sed -i "s|^$config_param=.*|$config_param=\"${!config_param}\"|" .env
    else
        echo "$config_param=\"${!config_param}\"" >> .env
    fi
}

main
