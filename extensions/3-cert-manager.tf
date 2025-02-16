locals {
  cert_manager_namespace = "cert-manager"

  cert_manager_service_account_name = "cert-manager"
  # TODO is it always "cert-manager"? Or is the release name? Or the namespace?
}

# OIDC PROVIDER

# TODO depends_on dns-records

data "tls_certificate" "cluster_tls_certificate" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_tls_certificate.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  #   tags = {
  #     IaCModule   = "eks-cluster/oidc-provider"
  #     ClusterName = var.cluster_name
  #   }
}

# Cert manager role

# This role is necessary to solve the DNS-01 challenge.

resource "aws_iam_role" "cert_manager_role" {
  name               = "cert-manager-route53-access-role"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role.json
}

data "aws_iam_policy_document" "cert_manager_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.cert_manager_namespace}:${local.cert_manager_service_account_name}"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.cert_manager_role.name
  policy_arn = aws_iam_policy.cert_manager_policy.arn
}

resource "aws_iam_policy" "cert_manager_policy" {
  name   = "cert-manager-route53-access-policy"
  policy = data.aws_iam_policy_document.policy_statements.json
}

data "aws_iam_policy_document" "policy_statements" {

  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/${data.aws_route53_zone.registered_domain_zone.id}"]
    # TODO local.zone_id instead of data.aws_route53_zone.x.id?
  }
}


# Ref: Installing cert-manager with Helm
# https://cert-manager.io/docs/installation/helm/

# Ref: Terraform resource: helm_release
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release

# Ref: cert-manager values.yaml
# https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml

resource "helm_release" "cert_manager" {

  name             = "cert-manager"
  namespace        = local.cert_manager_namespace
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.15.0"

  timeout       = 240
  wait          = true
  wait_for_jobs = true

  values = [yamlencode({

    crds = {

      # This option decides if the CRDs (issuer, clusterissuer, certificate, certificaterequest, order, challenge) should be installed as part of the Helm installation.
      enabled = true

      # This option makes it so that the "helm.sh/resource-policy": keep
      # annotation is added to the CRD. This will prevent Helm from uninstalling
      # the CRD when the Helm release is uninstalled.
      # WARNING: when the CRDs are removed, all cert-manager custom resources
      # (Certificates, Issuers, ...) will be removed too by the garbage collector.
      keep = true
    }

    # DNS-01 Route53
    serviceAccount = {
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.cert_manager_role.arn
      }
    }
    # "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.cert_manager_role.arn

    # prometheus:
    #   enabled: true
    #   servicemonitor:
    #     enabled: true
    #     prometheusInstance: lesson-083

    # Additional command line flags to pass to cert-manager controller binary.
    # To see all available flags run `docker run quay.io/jetstack/cert-manager-controller:v<version> --help`.
    extraArgs = [

      # Whether a cluster-issuer may make use of ambient credentials for issuers.
      # 'Ambient Credentials' are credentials drawn from the environment, metadata services, or local files
      # which are not explicitly configured in the ClusterIssuer API object.
      # When this flag is enabled, the following sources for credentials are also used:
      # AWS - All sources the Go SDK defaults to, notably including any EC2 IAM roles available via instance metadata. (default true)
      # Note: Need this arg to be able to use the IAM role.
      "--cluster-issuer-ambient-credentials",

      # Namespace to store resources owned by cluster scoped resources such as ClusterIssuer in.
      # This must be specified if ClusterIssuers are enabled. (default "kube-system")
      "--cluster-resource-namespace=${local.cert_manager_namespace}",
    ]

    # TODO ? --leader-election-namespace string
    # Namespace used to perform leader election. Only used if leader election is enabled (default "kube-system")
  })]
}
