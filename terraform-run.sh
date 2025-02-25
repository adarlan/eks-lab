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
    (
        set -ex
        terraform -chdir=$dir init
    )
fi

if $destroy; then
    operation=destroy
    echo; echo "Destroying $dir"
else
    operation=apply
    echo; echo "Applying $dir"
fi

approval_mode=$($no_prompt && echo "-auto-approve" || echo "")

(
    set -ex
    terraform -chdir=$dir $operation $approval_mode
)
