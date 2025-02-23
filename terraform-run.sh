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

if $destroy; then
    operation=destroy
else
    operation=apply
fi

terraform_args=$($no_prompt && echo "-auto-approve" || echo "")

./terraform-config.sh --no-prompt --dir $dir

if grep -Fxq "  cloud {}" $dir/terraform.tf; then
    source $dir/terraform.cloud.env
fi

if ! $no_init; then
    echo; echo "Initializing $dir"
    (
        set -ex
        terraform -chdir=$dir init
    )
fi

if [[ "$operation" == "apply" ]]; then
    echo; echo "Applying $dir"
elif [[ "$operation" == "destroy" ]]; then
    echo; echo "Destroying $dir"
fi

(
    set -ex
    terraform -chdir=$dir $operation $terraform_args
)
