#!/bin/bash
set -e
cd $(dirname $0)

./update-kubeconfig.sh

secrets=$(
    kubectl get secrets -A --no-headers \
    -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name" \
    | grep '\-tls$'
)

if [ "$secrets" = "" ]; then
    echo; echo "No TLS secrets to backup"
else

    echo; echo "Retrieving TLS secrets bucket name..."
    ./terraform-wrapper.sh cloud-setup --init >/dev/null
    source cloud-setup/terraform.env
    output_json=$(terraform -chdir=cloud-setup output -json tls_secrets_bucket_name)
    tls_secrets_bucket_name=$(echo "$output_json" | jq -r '.')
    echo "> $tls_secrets_bucket_name"

    while read -r namespace name; do

        file=$(mktemp)

        kubectl get secret -n "$namespace" "$name" -o json | jq '{
            apiVersion,
            data,
            kind,
            type,
            metadata: {
                annotations: (.metadata.annotations // {} | del(."kubectl.kubernetes.io/last-applied-configuration")),
                labels: .metadata.labels,
                name: .metadata.name,
                namespace: .metadata.namespace
            }
        }' > $file

        echo; echo "Backing up $name secret..."
        (set -ex; aws s3 cp $file s3://$tls_secrets_bucket_name/$name.json)

    done <<< "$secrets"
fi
