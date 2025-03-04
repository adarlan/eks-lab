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
    echo "export TF_CLOUD_ORGANIZATION=\"$tf_organization\"" >> $dir/terraform.env
    echo "export TF_WORKSPACE=\"$tf_workspace\"" >> $dir/terraform.env
    source $dir/terraform.env
fi

init=false
apply=false
destroy=false

for arg in "$@"; do
    if [[ "$arg" == "--init" ]]; then init=true; fi
    if [[ "$arg" == "--apply" ]]; then apply=true; fi
    if [[ "$arg" == "--destroy" ]]; then destroy=true; fi
    if [[ "$arg" == "--auto-approve" ]]; then auto_approve_config="-auto-approve"; fi
done

if $init; then
    terraform -chdir=$dir init
fi

if $apply; then
    terraform -chdir=$dir apply $auto_approve_config
fi

if $destroy; then
    terraform -chdir=$dir destroy $auto_approve_config
fi
