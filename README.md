# EKS Lab

An __Amazon Elastic Kubernetes Service__ (__EKS__) experimentation project that automates the deployment of a Kubernetes cluster, pre-integrated with open-source tools and example applications.

## Key Components 🛠️

- __Amazon EKS__ – Managed __Kubernetes__ cluster
- __Amazon VPC__ – Networking setup for the cluster
- __Amazon Route 53__ – DNS management
- __Amazon IAM__ + __OpenID Connect__ – Secure AWS authentication without static credentials
- __Terraform__ + __HCP Terraform__ – Infrastructure as code with remote execution and state management
- __GitHub Actions__ – Automated workflows
- __Argo CD__ – Continuous delivery
- __Ingress-Nginx__ – Traffic routing
- __Cert-Manager__ + __Let’s Encrypt__ – Automated TLS certificate issuance
- __Prometheus__ – Metrics scraping
- __Grafana__ – Dashboard visualization
- __Docker__ – Container image building
- __Amazon ECR__ – Container image storage
- __Helm__ – Kubernetes manifest packaging

## Prerequisites 📋

- __AWS account__ – With the AWS CLI installed and configured for administrator access.
- __GitHub account__ – With the GitHub CLI installed and authenticated.
- __HCP Terraform account__ – With the Terraform CLI installed and authenticated.
- __Registered domain__ – From any domain registrar.
- __Amazon Route 53 hosted zone__ – Configured for your domain, with its name servers set in your domain’s DNS settings.

## 1. Create Your Own Private Repository 🔒

Since this project requires configurations for your cloud accounts, it's recommended to work on your own private repository. GitHub doesn't allow changing a fork’s visibility to private, so instead of forking, you'll need to clone the repository and push it to a new private repository. Follow these steps:

```shell
# Create a new private repository in your account
gh repo create my-private-eks-lab --private

# Clone the public repository
git clone https://github.com/adarlan/eks-lab.git my-private-eks-lab

# Navigate into the project directory
cd my-private-eks-lab

# Set the 'origin' remote to your new private repository
git remote set-url origin git@github.com:$(gh api user --jq .login)/my-private-eks-lab.git

# Push the code to your private repository
git push -u origin main
```

<!-- To pull updates from the public repository:

```shell
# Add the 'upstream' remote URL
git remote add upstream https://github.com/adarlan/eks-lab.git

# Set your private repository as default
gh repo set-default $(gh api user --jq .login)/my-private-eks-lab

# Fetch and merge updates
git fetch upstream
git merge upstream/main
``` -->

## 2. Cloud Setup 🌥️

This repository is organized into multiple modules, each with its own independent configuration. Among them, `cloud-setup` is a foundational module. While it doesn’t provision the cluster infrastructure or deploy workloads, it establishes the necessary integrations between AWS, GitHub, and HCP Terraform, ensuring other modules have the required configurations, credentials, and permissions. It provisions:

- AWS IAM roles and OIDC providers for HCP Terraform and GitHub Actions
- HCP Terraform workspaces, variables, and API tokens
- GitHub secrets and variables for workflows

Create a `cloud-setup/terraform.tfvars` file and populate it with your values:

```conf
github_repo_name    = "my-private-eks-lab" # Name of your private GitHub repository where the project is hosted.
aws_region          = "us-east-1"          # AWS region where the infrastructure will be deployed.
hcp_tf_organization = "foo-bar"            # Name of your HCP Terraform organization, matching the one in your HCP Terraform account.
registered_domain   = "example.com"        # Primary domain used for cluster ingress and DNS configurations.
acme_email          = "foo@example.com"    # Contact email for the ACME account, required for issuing TLS certificates via Let's Encrypt.
ingress_hosts = { 
  # Maps applications and services to their respective domains or subdomains, enabling ingress routing within the cluster.
  hello_world = "hello.example.com"
  crud_api    = "crud.example.com"
  argocd      = "argocd.example.com"
  grafana     = "grafana.example.com"
  prometheus  = "prometheus.example.com"
}
```

Create a workspace for storing the cloud-setup Terraform state:

```shell
./create-cloud-setup-workspace.sh
```

Initialize and apply the cloud-setup configuration:

```shell
./terraform-wrapper.sh cloud-setup --init --apply
```

## 3. Deploy 🚀

With the foundational setup complete, trigger the deployment workflow to:

- Provision the EKS cluster and supporting infrastructure (VPC, Route 53, etc.)
- Create Kubernetes namespaces and apply Custom Resource Definitions (CRDs)
- Install essential tools and services (Ingress-Nginx, Cert-Manager, etc.)
- Build and deploy example applications (a Hello World app and a CRUD API with its client)

To start the deployment:

- Go to your GitHub repository
- Navigate to the __Actions__ tab
- Select the __Deploy__ workflow
- Click __Run workflow__

Once triggered, you can monitor the workflow progress in GitHub Actions:

![Deploy Workflow](./docs/deploy-workflow.png)

## 4. Next Steps 🎯

- Access your applications via the configured domain
- Monitor metrics with Grafana and Prometheus
- Experiment with Kubernetes workloads

## 5. Destroy 💥

To delete resources and avoid unnecessary costs:

- Go to your GitHub repository
- Navigate to the __Actions__ tab
- Select the __Undeploy__ workflow
- Click __Run workflow__
