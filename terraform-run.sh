#!/bin/bash
set -e
cd $(dirname $0)
dir=$(basename $1)

no_prompt=false
init=false
no_init=false
apply=false
destroy=false
shell=false

for arg in "$@"; do
    if [[ "$arg" == "--no-prompt" ]]; then no_prompt=true; fi
    if [[ "$arg" == "--init" ]]; then init=true; fi
    if [[ "$arg" == "--no-init" ]]; then no_init=true; fi
    if [[ "$arg" == "--destroy" ]]; then destroy=true; fi
    if [[ "$arg" == "--apply" ]]; then apply=true; fi
    if [[ "$arg" == "--shell" ]]; then shell=true; fi
done

if $apply && ! $no_init; then
    init=true
fi

if $destroy && ! $no_init; then
    init=true
fi

if grep -Fxq "  cloud {}" $dir/terraform.tf; then

    gh_variables=$(gh variable list --json name,value  | jq -r 'map({(.name): .value}) | add')

    export TF_CLOUD_ORGANIZATION=$(echo "$gh_variables" | jq -r '.TF_CLOUD_ORGANIZATION')
    export TF_CLOUD_PROJECT=$(echo "$gh_variables" | jq -r '.TF_CLOUD_PROJECT')
    export TF_WORKSPACE="$TF_CLOUD_PROJECT-$dir"
fi

if $init; then
    echo; echo "Initializing $dir"
    (set -ex; terraform -chdir=$dir init)
fi

auto_approve_config=$($no_prompt && echo "-auto-approve" || echo "")

if $apply; then
    echo; echo "Applying $dir"
    (set -ex; terraform -chdir=$dir apply $auto_approve_config)
elif $destroy; then
    echo; echo "Destroying $dir"
    (set -ex; terraform -chdir=$dir destroy $auto_approve_config)
fi

if $shell; then
    cd $dir
    sh
fi
