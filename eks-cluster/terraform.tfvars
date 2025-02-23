aws_region = "<AWS_REGION>"

aws_default_tags = {
  project = "<PROJECT>"
}

project                = "<PROJECT>"
cluster_name           = "<CLUSTER_NAME>"
cluster_administrators = ["<AWS_IAM_USER>"]
instance_type          = "t3.medium"
instance_count         = 2

cluster_admin_roles = [
  "<PROJECT>-namespace-governance",
  "<PROJECT>-ingress-nginx",
  "<PROJECT>-cert-manager",
  "<PROJECT>-kube-prometheus-stack",
  "<PROJECT>-argo-cd",
]
