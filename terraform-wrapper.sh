#!/bin/bash
set -e

cd $1
dir=$(basename $(pwd))
cd - >/dev/null
cd $(dirname $0)

gh_repo_name=$(gh repo view --json name -q '.name')
tf_organization=$(sed -n "s/^[[:space:]]*hcp_terraform_organization[[:space:]]*=[[:space:]]*\"\(.*\)\".*/\1/p" cloud-setup/terraform.tfvars)
tf_workspace="$gh_repo_name-$dir"

if grep -Fxq "  cloud {}" $dir/terraform.tf; then
    > $dir/terraform.env
    echo "export TF_WORKSPACE=\"$tf_workspace\"" >> $dir/terraform.env
    echo "export TF_CLOUD_ORGANIZATION=\"$tf_organization\"" >> $dir/terraform.env
    source $dir/terraform.env
fi

tf_command=apply
for arg in "$@"; do
    if [[ "$arg" == "--destroy" ]]; then tf_command=destroy; fi
    if [[ "$arg" == "--auto-approve" ]]; then auto_approve_config="-auto-approve"; fi
done

terraform -chdir=$dir init
terraform -chdir=$dir $tf_command $auto_approve_config

# TODO export each output as a variable, to be sourced into other scripts
