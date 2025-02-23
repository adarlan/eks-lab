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

Ensure you have the following __accounts__:

- [Amazon Web Services (AWS)](https://aws.amazon.com/)
- [GitHub](https://github.com/)
- [HashiCorp Cloud Platform (HCP) Terraform](https://app.terraform.io/)

You’ll also need their respective __CLI tools__ configured:

- `aws`
- `gh`
- `terraform`

Additionally, you need a __registered domain__, which can be with any registrar, as long as you have a __Route 53 hosted zone__ set up as the DNS service.

## Getting Started

### 1. 📁 Fork & Clone the Repository

Since this project requires configurations for your cloud accounts, work on your own fork.

```shell
gh repo fork adarlan/eks-lab --clone
cd eks-lab
```

### 2. 🏗️ Terraform Configuration

The Terraform configurations in this repository contain placeholders in `terraform.tfvars` that must be replaced with actual values.
You can do this manually or automate the process using a script.

#### Option 1: Manual Configuration

Edit the `terraform.tfvars` files and replace all placeholders.

Example:

```diff
- aws_region = "<AWS_REGION>"
+ aws_region = "us-east-1"

- cluster_name = "<CLUSTER_NAME>"
+ cluster_name = "eks-lab"
```

To find all placeholders, search for `<[A-Z_]+>` pattern across the repository.

#### Option 2: Automated Configuration

Run the following script to generate `terraform.auto.tfvars` files, replacing the placeholder values from `terraform.tfvars`:

```shell
./generate-terraform-auto-tfvars.sh
```

This script will:

- Prompt you for any required information
- Save your inputs in a `.env` file for future runs
- Generate `terraform.auto.tfvars` files with the correct values

Using `terraform.auto.tfvars` ensures Terraform picks up the correct configuration automatically, without modifying `terraform.tfvars` manually.

### 3. 🌥️ Cloud Setup

The `cloud-setup` directory contains Terraform configurations to integrate AWS, GitHub and HCP Terraform.

This setup includes configuring the following resources:

- HCP Terraform project, workspaces, variables, and token
- AWS IAM roles and OIDC providers
- GitHub Actions variables and secrets

Run the following commands to apply these configurations:

```shell
terraform -chdir=cloud-setup init
terraform -chdir=cloud-setup apply
```

### 4. 🚀 Deploy

You're now ready to:

- Create the EKS cluster and required infrastructure (VPC, Route 53, etc.)
- Install necessary tools (Ingress-Nginx, Cert-Manager, etc.)
- Deploy example applications

If you have any changes, __commit and push__ them before proceeding.

To deploy, go to your GitHub repository:

- Navigate to the __Actions__ tab
- Select the __Deploy__ workflow
- Click __Run workflow__

### Next Steps

- Access your applications via the configured domain
- Monitor metrics using Grafana and Prometheus
- Automate further deployments using Argo CD
- Experiment with Kubernetes workloads
- Destroy to avoid unnecessary costs
