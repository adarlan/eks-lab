# EKS Lab

An __Amazon EKS__ experimentation project, packed with open-source tools and example applications.
It automates __Kubernetes__ cluster setup using __Terraform__ and __Helm__, integrating:
__Amazon VPC__ for networking,
__Amazon Route 53__ for DNS management,
__Ingress-Nginx__ for traffic routing,
__Cert-Manager__ for automated TLS certificate issuance,
__Argo CD__ for continuous deployment,
__Prometheus__ for metrics scraping,
and __Grafana__ for dashboard visualization.

## Setup

### Requirements

Cloud platform accounts:

- Amazon Web Services (AWS) account
- GitHub account
- HashiCorp Cloud Platform (HCP) Terraform account and organization

And their respective CLIs configured to access the accounts:

- `aws`
- `gh`
- `terraform`

You also need a registered domain.
It can be registered in any domain registrar,
since you have a Route 53 hosted zone configured as DNS server.

## Setup

### Fork & Clone

Fork this repository to your GitHub account and clone your fork on your computer.
As this project requires configurations to access your cloud platform accounts,
you need to work on your own repository.

Example (cloning the repository with GitHub CLI, but feel free to clone with git over HTTPS or SSH):

```shell
gh repo clone GITHUB_USER/eks-lab
cd eks-lab
```

### Configure `.env` File

Create an `.env` file with some basic configurations.

The Terraform configurations in this repository contain placeholders,
and the data in the .env file will be used to replace them.

This script will help you create the `.env` file quickly:

```shell
./configure-dot-env.sh
```

If you prefer to create it manually, this is how your `.env` file should look like:

```shell
PROJECT="eks-lab"
AWS_REGION="us-east-1"
DOMAIN="example.com"
APPLICATION_HOST="app.example.com"
ACME_EMAIL="john.doe@example.com"
ORGANIZATION="john-doe"
CLUSTER_NAME="eks-lab"
GITHUB_REPOSITORY="eks-lab"
ARGOCD_HOST="argocd.example.com"
GRAFANA_HOST="grafana.example.com"
PROMETHEUS_HOST="prometheus.example.com"
```

### Generate `terraform.auto.tfvars` Files

This project has multiple Terraform configurations.
They contain a `terraform.tfvars` file with some placeholders.
You need to generate a `terraform.auto.tfvars` with placeholders replaced by the values configured on the `.env` file.

> When a Terraform configuration contains both `terraform.tfvars` and `terraform.auto.tfvars` files, `terraform.auto.tfvars` takes precedence.

This script will help you generate the `terraform.auto.tfvars` files quickly:

```shell
./generate-terraform-auto-tfvars.sh
```

If you prefer, instead of generating these files, you can manually edit the terraform.tfvars files and replace the placeholders.

### Cloud Setup

The `cloud-setup` directory contains the Terraform configuration to create the configurations and credentials necessary to integrate the 3 platforms.
It creates HCP Terraform project, workspaces, variables and token, AWS IAM roles and OIDC providers, and GitHub Actions secrets.

Run the commands below to create these resources:

```shell
terraform -chdir=cloud-setup init
terraform -chdir=cloud-setup apply
```

### Deploy

You're all set to create the EKS cluster along with all the required infrastructure (VPC network, Route53 DNS, etc),
install tools (ingress-nginx, cert-manager, etc),
and deploy example applications.

If you have changes to commit, do it and push them.

On your repository on GitHub, navigate to the Actions tab,
select the Deploy workflow on the left menu,
and click "Run workflow" on the right.

<!-- TODO screenshots -->
