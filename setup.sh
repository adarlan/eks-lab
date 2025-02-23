#!/bin/bash
set -e
cd $(dirname $0)

if [[ $# -eq 0 || $1 == --* ]]; then
    item=all
else
    item=$(basename $1)
fi

destroy=false
auto=false
skip_terraform_init=false
for arg in "$@"; do
    if [[ "$arg" == "--destroy" ]]; then destroy=true; fi
    if [[ "$arg" == "--auto" ]]; then auto=true; fi
    if [[ "$arg" == "--skip-terraform-init" ]]; then skip_terraform_init=true; fi
done

reset_dot_env=false
if [[ $item == .env ]]; then
    reset_dot_env=true
elif [[ $item == .tfvars ]]; then
    cmd="_generate_all_terraform_auto_tfvars"
else
    cmd=$item
    if $destroy; then
        cmd=destroy-$item
    fi
fi

all() {
    cloud-setup
    vpc-network
    eks-cluster
    namespace-governance
    crds
    ingress-nginx
    # route53-dns
    cert-manager
    kube-prometheus-stack
    argo-cd
    hello-world
    # argocd-applications

    # TODO need to wait until all certificates are issued
    # tls-secrets-backup
}

destroy-all() {
    # Destroy all except cloud-setup

    tls-secrets-backup

    # undeploy-argocd-applications || :
    # undeploy-hello-world

    destroy-argo-cd || :
    destroy-kube-prometheus-stack || :

    destroy-cert-manager # || delete-cert-manager-aws-resources
    destroy-ingress-nginx # || delete-ingress-nginx-aws-resources

    # uninstall-crds

    destroy-namespace-governance || :

    destroy-eks-cluster
    destroy-vpc-network

    # destroy-cloud-setup
}

cloud-setup() {
    _terraform_command apply cloud-setup "local"
}

vpc-network() {
    _terraform_command apply vpc-network "cloud"
}

eks-cluster() {
    _terraform_command apply eks-cluster "cloud"
}

namespace-governance() {
    _terraform_command apply namespace-governance "cloud"
}

ingress-nginx() {
    _terraform_command apply ingress-nginx "cloud"
}

cert-manager() {
    _terraform_command apply cert-manager "cloud"
}

kube-prometheus-stack() {
    _terraform_command apply kube-prometheus-stack "cloud"
}

argo-cd() {
    _terraform_command apply argo-cd "cloud"
}

destroy-vpc-network() {
    _terraform_command destroy vpc-network "cloud"
}

destroy-eks-cluster() {
    _terraform_command destroy eks-cluster "cloud"
}

destroy-namespace-governance() {
    _terraform_command destroy namespace-governance "cloud"
}

destroy-ingress-nginx() {
    _terraform_command destroy ingress-nginx "cloud"
}

destroy-cert-manager() {
    _terraform_command destroy cert-manager "cloud"
}

destroy-kube-prometheus-stack() {
    _terraform_command destroy kube-prometheus-stack "cloud"
}

destroy-argo-cd() {
    _terraform_command destroy argo-cd "cloud"
}

_terraform_command() {

    operation=$1
    dir=$2
    state_type=$3
    terraform_args=$($auto && echo "-auto-approve" || echo "")

    _generate_terraform_auto_tfvars $dir

    if [[ "$state_type" == "cloud" ]]; then
        export TF_CLOUD_ORGANIZATION="$ORGANIZATION"
        export TF_WORKSPACE="$PROJECT-$dir"
    fi

    if ! $skip_terraform_init; then
        echo; echo "Initializing $dir Terraform configuration"
        (
            set -ex
            terraform -chdir=$dir init
        )
    fi

    if [[ "$operation" == "apply" ]]; then
        echo; echo "Applying $dir Terraform configuration"
    elif [[ "$operation" == "destroy" ]]; then
        echo; echo "Destroying $dir"
    fi
    (
        set -ex
        terraform -chdir=$dir $operation $terraform_args
    )
}

kubeconfig() {
    echo; echo "Configuring kubectl"
    (
        set -ex
        aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION --profile $AWS_PROFILE
    )
}

crds() {
    kubeconfig

    echo; echo "Applying CRDs"
    (
        set -ex
        kubectl apply --server-side -k crds/
    )
}

tls-secrets-backup() {

    kubeconfig

    secrets=$(
        kubectl get secrets -A --no-headers \
        -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name" \
        | grep '\-tls$'
    )

    if [ "$secrets" = "" ]; then
        echo; echo "No TLS secrets to backup"
    else
        tls_secrets_bucket_name=$(terraform -chdir=cloud-setup output -raw tls_secrets_bucket_name)

        while read -r namespace name; do

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
            }' > $name.json

            echo; echo "Backing up $name secret"
            (
                set -ex
                aws --profile $AWS_PROFILE s3 cp $name.json s3://$tls_secrets_bucket_name/$name.json
            )

        done <<< "$secrets"
    fi
}

hello-world() {
    kubeconfig

    echo; echo "Deploying hello-world application"
    (
        set -ex
        helm upgrade --install hello-world ./helm-charts/hello-world/ \
            --namespace default \
            --set message="Hello World" \
            --set ingress.host=$APPLICATION_HOST
    )
}

_generate_terraform_auto_tfvars() {
    dir=$1
    echo; echo "Generating $dir/terraform.auto.tfvars file"
    echo "# WARNING: This file is automatically generated. Do NOT edit manually!" > $dir/terraform.auto.tfvars
    echo "# To make changes, update the $dir/terraform.tfvars or .env file instead." >> $dir/terraform.auto.tfvars
    echo "" >> $dir/terraform.auto.tfvars
    cat $dir/terraform.tfvars >> $dir/terraform.auto.tfvars
    variables=$(grep -E -o '^[A-Z0-9_]+' .env)
    for variable in $variables; do
        value="${!variable}"
        if grep -q "<$variable>" $dir/terraform.auto.tfvars > /dev/null; then
            echo "- Replacing placeholder: <$variable> ---> $value"
            sed -i.bak -e "s|<$variable>|$value|g" $dir/terraform.auto.tfvars
            rm $dir/terraform.auto.tfvars.bak
        fi
    done
}

_generate_all_terraform_auto_tfvars() {
    for dir in */; do
        dir=$(basename $dir)
        if [ -d "$dir" ] && [ -f $dir/terraform.tfvars ]; then
            _generate_terraform_auto_tfvars $dir
        fi
    done
}

_read_dot_env() {

    if [ -f .env ]; then
        source .env
    else
        touch .env
        reset_dot_env=true
    fi

    if $reset_dot_env; then
        echo; echo "Configuring .env"
    else
        echo; echo "Reading .env"
    fi

    _read_dot_env_var PROJECT           'basename $(pwd)'
    _read_dot_env_var AWS_PROFILE       'echo "default"'
    _read_dot_env_var AWS_IAM_USER      'aws --profile=$AWS_PROFILE iam get-user --query "User.UserName" --output text'
    _read_dot_env_var AWS_REGION        'aws --profile=$AWS_PROFILE configure get region || echo "us-east-1"'
    _read_dot_env_var DOMAIN            'echo "example.com"'
    _read_dot_env_var APPLICATION_HOST  'echo "app.$DOMAIN"'
    _read_dot_env_var ACME_EMAIL        'gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /user/public_emails | jq -r .[0].email'
    _read_dot_env_var ORGANIZATION      'echo ""'
    _read_dot_env_var CLUSTER_NAME      'echo "$PROJECT"'
    _read_dot_env_var GITHUB_REPOSITORY 'echo "$PROJECT"'
    _read_dot_env_var ARGOCD_HOST       'echo "argocd.$DOMAIN"'
    _read_dot_env_var GRAFANA_HOST      'echo "grafana.$DOMAIN"'
    _read_dot_env_var PROMETHEUS_HOST   'echo "prometheus.$DOMAIN"'
}

_read_dot_env_var() {

    var="$1"
    default_value_cmd="$2"

    if [ "${!var}" != "" ]; then
        default_value="${!var}"
    elif ! default_value="$(eval $default_value_cmd)"; then
        default_value=""
    fi

    if $reset_dot_env || [ "${!var}" = "" ]; then

        if $auto; then
            echo; echo "[ERROR] $var is not set"
            exit 1
        fi

        read -p "- $var ($default_value): " "$var"
        if [ "${!var}" = "" ]; then
            eval "$var=\"$default_value\""
        fi
    else
        eval "$var=\"$default_value\""
        echo "- $var: ${!var}"
    fi

    if grep -q "^${var}=" .env > /dev/null; then
        sed -i.bak "s|^$var=.*|$var=\"${!var}\"|" .env
        rm .env.bak
    else
        echo "$var=\"${!var}\"" >> .env
    fi
}

_read_dot_env
$cmd
