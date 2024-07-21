aws_region = "__AWS_REGION__"

aws_default_tags = {
  IaCRepository = "github.com/__GITHUB_OWNER__/__PLATFORM_NAME__-cluster-tools"
}

cluster_name = "__PLATFORM_NAME__-cluster"

domain_name = "__DOMAIN_NAME__"

acme_email = "__ACME_EMAIL__"

# Set to true to create and manage the Route 53 zone through this Terraform configuration.
# Only if the domain is registered on Amazon Route 53.
create_route53_zone = false

# ingress_hosts = ["*.__BASE_HOST__"]

# For domain and all its subdomains:
# ingress_hosts = ["example.com", "*.example.com"]

# For domain only:
# ingress_hosts = ["example.com"]

# For domain and specific subdomains:
# ingress_hosts = ["example.com", "foo.example.com", "bar.example.com"]

# For specific subdomains:
# ingress_hosts = ["foo.example.com", "bar.example.com"]

# For all subdomains:
# ingress_hosts = ["*.example.com"]

loki_s3_bucket_name = "__PLATFORM_NAME__-loki-chunks-__RANDOM_STRING__"
