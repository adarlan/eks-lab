#!/bin/bash
set -e
cd $(dirname $0)

echo; echo "Retrieving EKS cluster name and AWS region..."
./terraform-wrapper.sh cloud-setup --init >/dev/null
source cloud-setup/terraform.env

output_json=$(terraform -chdir=cloud-setup output -json cluster_name)
cluster_name=$(echo "$output_json" | jq -r '.')
echo "> $cluster_name"

output_json=$(terraform -chdir=cloud-setup output -json aws_region)
aws_region=$(echo "$output_json" | jq -r '.')
echo "> $aws_region"

echo; echo "Updating kubeconfig..."
(set -ex; aws eks update-kubeconfig --name "$cluster_name" --region "$aws_region")
