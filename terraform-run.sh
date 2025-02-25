#!/bin/bash
set -e
cd $(dirname $0)
dir=$(basename $1)

destroy=false
no_prompt=false
no_init=false
for arg in "$@"; do
    if [[ "$arg" == "--destroy" ]]; then destroy=true; fi
    if [[ "$arg" == "--no-prompt" ]]; then no_prompt=true; fi
    if [[ "$arg" == "--no-init" ]]; then no_init=true; fi
done

if grep -Fxq "  cloud {}" $dir/terraform.tf; then
    gh_variables=$(gh variable list --json name,value  | jq -r 'map({(.name): .value}) | add')
    export TF_CLOUD_ORGANIZATION=$(echo "$gh_variables" | jq -r '.TF_CLOUD_ORGANIZATION')
    export TF_CLOUD_PROJECT=$(echo "$gh_variables" | jq -r '.TF_CLOUD_PROJECT')
    export TF_WORKSPACE="$TF_CLOUD_PROJECT-$dir"
fi

if ! $no_init; then
    echo; echo "Initializing $dir"
    (set -ex; terraform -chdir=$dir init)
fi

auto_approve_config=$($no_prompt && echo "-auto-approve" || echo "")
if $destroy; then
    echo; echo "Destroying $dir"
    (set -ex; terraform -chdir=$dir destroy $auto_approve_config)
else
    echo; echo "Applying $dir"
    (set -ex; terraform -chdir=$dir apply $auto_approve_config)
fi
