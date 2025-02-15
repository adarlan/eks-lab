# Ref: Installing cert-manager with Helm
# https://cert-manager.io/docs/installation/helm/

# Ref: Terraform resource: helm_release
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release

# Ref: cert-manager values.yaml
# https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml

resource "helm_release" "cert_manager" {

  name             = var.helm_release_name
  namespace        = var.namespace
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.15.0"

  timeout       = 240
  wait          = true
  wait_for_jobs = true

  dynamic "set" {
    for_each = local.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}

locals {
  helm_values = {

    # This option decides if the CRDs (issuer, clusterissuer, certificate, certificaterequest, order, challenge) should be installed as part of the Helm installation.
    "crds.enabled" = true

    # This option makes it so that the "helm.sh/resource-policy": keep
    # annotation is added to the CRD. This will prevent Helm from uninstalling
    # the CRD when the Helm release is uninstalled.
    # WARNING: when the CRDs are removed, all cert-manager custom resources
    # (Certificates, Issuers, ...) will be removed too by the garbage collector.
    "crds.keep" = true

    # DNS-01 Route53
    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.role.arn

    # prometheus:
    #   enabled: true
    #   servicemonitor:
    #     enabled: true
    #     prometheusInstance: lesson-083

    # Additional command line flags to pass to cert-manager controller binary.
    # To see all available flags run `docker run quay.io/jetstack/cert-manager-controller:v<version> --help`.

    # Whether a cluster-issuer may make use of ambient credentials for issuers.
    # 'Ambient Credentials' are credentials drawn from the environment, metadata services, or local files
    # which are not explicitly configured in the ClusterIssuer API object.
    # When this flag is enabled, the following sources for credentials are also used:
    # AWS - All sources the Go SDK defaults to, notably including any EC2 IAM roles available via instance metadata. (default true)
    # Note: Need this arg to be able to use the IAM role.
    "extraArgs[0]" = "--cluster-issuer-ambient-credentials"

    # Namespace to store resources owned by cluster scoped resources such as ClusterIssuer in.
    # This must be specified if ClusterIssuers are enabled. (default "kube-system")
    "extraArgs[1]" = "--cluster-resource-namespace=${var.namespace}"

    # TODO ? --leader-election-namespace string
    # Namespace used to perform leader election. Only used if leader election is enabled (default "kube-system")
  }
}
