#!/bin/bash
set -e
cd $(dirname $0)

# TODO initially, we will restore tls secrets using this script
# but this is not a good solution
# later we will need Velero? or external-secrets?

backup() {
    if [ -f tls-secrets-backup.yaml ]; then
        mv tls-secrets-backup.yaml tls-secrets-ignored-$(date +"%Y-%m-%d-%H-%M-%S").yaml
    fi
    touch tls-secrets-backup.yaml
    secrets=$(kubectl get secrets -A --no-headers -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name" | grep '\-tls$')
    while read -r namespace name; do
        echo "---" >> tls-secrets-backup.yaml
        kubectl get secret -n "$namespace" "$name" -o yaml >> tls-secrets-backup.yaml
    done <<< "$secrets"
}

restore() {
    if [ -f tls-secrets-backup.yaml ]; then
        kubectl apply -f tls-secrets-backup.yaml
        mv tls-secrets-backup.yaml tls-secrets-restored-$(date +"%Y-%m-%d-%H-%M-%S").yaml
    fi
}

$@
