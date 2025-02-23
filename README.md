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

## Requirements

Cloud platform accounts:

- Amazon Web Services (AWS) account
- GitHub account
- HashiCorp Cloud Platform (HCP) Terraform account

CLI tools installed:

- `aws` - AWS CLI configured with AWS IAM user credentials
- `gh` - GitHub CLI configured with GitHub user credentials
- `terraform` - Terraform CLI configured with HCP Terraform user credentials
- `kubectl`
- `helm`
- `argocd`

## Setup

### Fork & Clone

Fork this repository to your GitHub account and clone your fork on your computer.
As this project requires configurations and credentials to access your cloud platform accounts,
you need to work on your own repository.

Example (cloning the repository with GitHub CLI, but feel free to clone with git over HTTPS or SSH):

```shell
gh repo clone GITHUB_USER/eks-lab
cd eks-lab
```

### Configure `.env` File

Create an `.env` file with some basic configurations.

This command will help you create the `.env` file quickly:

```shell
./setup.sh .env
```

This is how your `.env` file will look like:

```shell
PROJECT="eks-lab"
AWS_PROFILE="default"
AWS_IAM_USER="john-doe"
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
When a Terraform configuration contains both `terraform.tfvars` and `terraform.auto.tfvars` files, `terraform.auto.tfvars` takes precedence.

This command will help you generate the `terraform.auto.tfvars` files quickly:

```shell
./setup.sh .tfvars
```

### Cloud Setup

The `cloud-setup` directory contains the Terraform configuration for
HCP Terraform project, workspaces, variables and token, AWS IAM roles and OIDC provider, and GitHub Actions secrets.

These resources are the configurations and credentials necessary to integrate the 3 platforms.

Run the commands below to create these resources:

```shell
terraform -chdir=cloud-setup init
terraform -chdir=cloud-setup apply
```

### Deploy

You're all set to create the EKS cluster along with all the required infrastructure (VPC network, Route53 DNS, etc),
install tools (ingress-nginx, cert-manager, etc),
and deploy example applications.

You can do this by either with GitHub Actions
or executing commands locally.

#### Deploy with GitHub Actions

On your repository on GitHub, navigate to the Actions tab,
select the Deploy workflow on the left menu,
and click "Run workflow" on the right.

<!-- TODO screenshots -->

#### Deploy with local commands

```shell
source .env
export TF_CLOUD_ORGANIZATION="$ORGANIZATION"

# VPC network
export TF_WORKSPACE="$PROJECT-vpc-network"
terraform -chdir vpc-network init
terraform -chdir vpc-network apply

# EKS cluster
export TF_WORKSPACE="$PROJECT-eks-cluster"
terraform -chdir eks-cluster init
terraform -chdir eks-cluster apply

# TODO add other components
```
