#!/bin/bash
set -ex

./terraform-run.sh kube-prometheus-stack/ --destroy --no-prompt
./terraform-run.sh argo-cd/ --destroy --no-prompt
./terraform-run.sh cert-manager/ --destroy --no-prompt
./terraform-run.sh ingress-nginx/ --destroy --no-prompt
./terraform-run.sh namespace-governance/ --destroy --no-prompt
./terraform-run.sh eks-cluster/ --destroy --no-prompt
./terraform-run.sh vpc-network/ --destroy --no-prompt
