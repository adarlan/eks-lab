# EKS Lab

This project automates the deployment of an Amazon EKS cluster on AWS using Terraform and GitHub Actions. Designed for experimentation, it comes pre-integrated with open-source tools and example applications.

## Key Components

- __Amazon EKS__ – Managed __Kubernetes__ cluster
- __Amazon VPC__ – Networking setup for the cluster
- __Amazon Route 53__ – DNS management
- __Terraform__ – Infrastructure as code, with __HCP Terraform__ for remote execution and state management
- __OpenID Connect__ – Secure AWS authentication without static credentials
- __GitHub Actions__ – Automated infrastructure provisioning
- __Argo CD__ – Continuous delivery for application deployment
- __Ingress-Nginx__ – Traffic routing for applications
- __Cert-Manager__ + __Let’s Encrypt__ – Automated TLS certificate issuance
- __Prometheus__ – Metrics scraping
- __Grafana__ – Dashboard visualization

<!-- - Docker for application container image building -->
<!-- - Amazon ECR for application container image storage -->
<!-- - Helm for application deployment packaging -->

<!-- Everything, from cluster creation to tool installation and application deployment, is defined as code, ensuring consistency and repeatability, eliminating the need for manual setup or local dependencies. -->

## Prerequisites

Ensure you have the following:

- AWS account
- GitHub account
- HCP Terraform account
- CLI tools installed and authenticated:
  - `aws` CLI configured with administrator access to your AWS account
  - `gh` CLI authenticated with your GitHub user
  - `terraform` CLI authenticated with your HCP Terraform user
- Registered domain (can be from any registrar)
- Amazon Route 53 hosted zone for your domain, with its name servers correctly configured in your domain’s DNS settings

## 1. Fork & Clone the Repository

Since this project requires configurations for your cloud accounts, it's recommended to work on your own fork.

```shell
gh repo fork adarlan/eks-lab --clone
cd eks-lab
```

## 2. Cloud Setup 🌥️

This repository is organized into multiple modules, each with its own independent configuration. Among them, `cloud-setup` is a foundational module. While it doesn’t provision the cluster infrastructure or deploy workloads, it establishes the necessary integrations between AWS, GitHub, and HCP Terraform, ensuring that all other modules have the required configurations, credentials, and permissions to function correctly.

It provisions:

- AWS IAM roles and OIDC providers, granting HCP Terraform and GitHub Actions the necessary permissions to manage AWS resources.
- HCP Terraform workspaces, variables, and API tokens, enabling GitHub Actions to run Terraform commands remotely.
- GitHub secrets and variables, supplying credentials and configuration details for the GitHub Actions workflows.

Before applying the setup, create a `cloud-setup/terraform.tfvars` file with the following values, replacing them as needed:

```conf
github_repository          = "eks-lab"
aws_region                 = "us-east-1"
hcp_terraform_organization = "example-org"

domain = "example.com"

hosts = {
  application = "app.example.com"
  argocd      = "argocd.example.com"
  grafana     = "grafana.example.com"
  prometheus  = "prometheus.example.com"
}

acme_email = "example@example.com"
```

Run the following commands to initialize and apply the `cloud-setup` module:

```shell
terraform -chdir=cloud-setup init
terraform -chdir=cloud-setup apply
```

This applies the `cloud-setup` configuration using the current user's credentials and stores the Terraform state locally.
However, this is the only module that runs locally — all other modules are applied via GitHub Actions and managed through HCP Terraform.

## 3. Deploy Infrastructure 🏗️

With the foundational setup complete, you're ready to deploy the core infrastructure components:

- Provision the EKS cluster along with supporting resources (VPC, Route 53, etc.).
- Create Kubernetes namespaces and apply Custom Resource Definitions (CRDs).
- Install essential tools and services (Ingress-Nginx, Cert-Manager, etc.)

To start the deployment:

- Go to your GitHub repository
- Navigate to the __Actions__ tab
- Select the __Deploy Infrastructure__ workflow
- Click __Run workflow__

Once triggered, the workflow progress will be visible in GitHub Actions, as illustrated below:

![Deploy Infrastructure](./docs/deploy-infrastructure.png)

## 4. Deploy Applications 📦

With the infrastructure in place, you can now deploy example applications to the cluster.

To start the deployment:

- Go to your GitHub repository
- Navigate to the __Actions__ tab
- Select the __Deploy Applications__ workflow
- Click __Run workflow__

## 5. Next Steps 🎯

- Access your applications via the configured domain
- Monitor metrics with Grafana and Prometheus
- Experiment with Kubernetes workloads

## 6. Undeploy Infrastructure 💥

Destroy resources when finished to avoid unnecessary costs:

- Go to your GitHub repository
- Navigate to the __Actions__ tab
- Select the __Undeploy Infrastructure__ workflow
- Click __Run workflow__
