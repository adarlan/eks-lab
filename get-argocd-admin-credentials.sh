#!/bin/bash
set -e
cd $(dirname $0)

dir=argo-cd

no_init=false

for arg in "$@"; do
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

echo; echo "Getting Argo CD admin credentials"
(set -ex; terraform -chdir=$dir output argocd_admin_credentials)
