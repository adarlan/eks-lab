#!/bin/bash
set -e
cd $(dirname $0)

# helm upgrade --install example    ./helm-charts/hello-world/ -n default --set message="Hello Example" --set ingress.host=example.adarlan.click
# helm upgrade --install grafana    ./helm-charts/hello-world/ -n grafana --create-namespace    --set message="Hello Grafana" --set ingress.host=grafana.adarlan.click
# helm upgrade --install prometheus ./helm-charts/hello-world/ -n prometheus --create-namespace --set message="Hello Prometheus" --set ingress.host=prometheus.adarlan.click
# helm upgrade --install host       ./helm-charts/hello-world/ -n host --create-namespace       --set message="Hello Host" --set ingress.host=adarlan.click

helm upgrade --install grafana    ./helm-charts/hello-world/ -n grafana --create-namespace    --set message="Hello Grafana" --set ingress.host=grafanoso.adarlan.click
helm upgrade --install prometheus ./helm-charts/hello-world/ -n prometheus --create-namespace --set message="Hello Prometheus" --set ingress.host=cumprius.example.adarlan.click

helm upgrade --install example    ./helm-charts/hello-world/ -n default --set message="Hello Example" --set ingress.host=foo.adarlan.click

helm upgrade --install pasta    ./helm-charts/hello-world/ -n default --set message="Hello Pasta" --set ingress.host=pasta.foo.adarlan.click
