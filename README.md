# EKS Lab

An __Amazon EKS__ experimentation project packed with open-source tools and example applications.

It automates __Kubernetes__ cluster setup using __Terraform__ and __Helm__, integrating:

- __Amazon VPC__ for networking
- __Amazon Route 53__ for DNS management
- __Ingress-Nginx__ for traffic routing
- __Cert-Manager__ for automated TLS certificate issuance
- __Prometheus__ for metrics scraping
- __Grafana__ for dashboard visualization
- __GitHub Actions__ for deployment automation
- __Argo CD__ for continuous deployment

## Prerequisites

Before getting started, ensure you have the following:

### Accounts

- [Amazon Web Services (AWS)](https://aws.amazon.com/)
- [GitHub](https://github.com/)
- [HashiCorp Cloud Platform (HCP) Terraform](https://app.terraform.io/)

### CLI Tools

- `aws`
- `gh`
- `terraform`

### Domain & DNS

You'll need a __registered domain__, which can be with any registrar. However, you must have an __Amazon Route 53 hosted zone__ set up as the DNS service.

## Getting Started

### 1️. Fork & Clone the Repository 📁

Since this project requires configurations for your cloud accounts, it's recommended to work on your own fork.

```shell
gh repo fork adarlan/eks-lab --clone
cd eks-lab
```

### 2️. Cloud Setup 🌥️

This repository is organized into multiple modules, each with its own independent Terraform configuration. Among them, `cloud-setup` is a foundational module. While it doesn’t provision the cluster infrastructure or deploy workloads, it establishes the necessary integrations between AWS, GitHub, and HCP Terraform, ensuring that all other modules have the required configurations, credentials, and permissions to function correctly.

It provisions:

- HCP Terraform workspaces, variables, and API token, enabling GitHub Actions to run Terraform commands remotely.
- AWS IAM roles and OIDC providers, granting HCP Terraform workspaces and GitHub Actions the necessary permissions to manage AWS resources.
- GitHub secrets and variables, supplying credentials and configuration details for the GitHub Actions workflows.

#### Configuration

Before applying the setup, create a `cloud-setup/terraform.tfvars` file with the following values, replacing them as needed:

```conf
project           = "eks-lab"
cluster_name      = "eks-lab"
github_repository = "eks-lab"
organization      = "example-organization"
team              = "owners"
aws_region        = "us-east-1"
domain            = "example.com"
application_host  = "app.example.com"
argocd_host       = "argocd.example.com"
grafana_host      = "grafana.example.com"
prometheus_host   = "prometheus.example.com"
acme_email        = "example@example.com"
```

#### Applying the Configuration

Run the following commands to initialize and apply the `cloud-setup` module:

```shell
terraform -chdir=cloud-setup init
terraform -chdir=cloud-setup apply
```

This applies the `cloud-setup` configuration using the current user's credentials and a local Terraform backend. However, this is the only module that runs locally — all other modules are applied via GitHub Actions and managed through HCP Terraform.

### 3️. Deploy 🚀

At this point, you're ready to:

- Create the EKS cluster and supporting infrastructure (VPC, Route 53, etc.)
- Install essential tools (Ingress-Nginx, Cert-Manager, etc.)
- Deploy example applications

Before proceeding, make sure to commit and push any changes.

Start the deployment:

- Go to your GitHub repository
- Navigate to the __Actions__ tab
- Select the __Deploy__ workflow
- Click __Run workflow__

### Next Steps 🎯

- Access your applications via the configured domain
- Monitor metrics with Grafana and Prometheus
- Automate deployments using Argo CD
- Experiment with Kubernetes workloads
- Destroy resources when finished to avoid unnecessary costs
