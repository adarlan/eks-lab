locals {
  release_name = "cert-manager"
  namespace    = "cert-manager"
}

# -----------------------------------------------------------------------------
# cert-manager release
# -----------------------------------------------------------------------------

resource "helm_release" "cert_manager" {
  # depends_on = [kubernetes_namespace.namespace]

  name      = local.release_name
  namespace = local.namespace

  create_namespace = true # TODO

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.15.0"

  wait = false

  # Configuration reference:
  # https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml
  values = [yamlencode({

    crds = {
      enabled = false
    }

    # DNS-01 Route53
    serviceAccount = {
      name = local.service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.cert_manager_role.arn
      }
    }

    # TODO
    # prometheus:
    #   enabled: true
    #   servicemonitor:
    #     enabled: true
    #     prometheusInstance: lesson-083

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
      "--cluster-resource-namespace=${local.namespace}",
    ]

    # TODO ? --leader-election-namespace string
    # Namespace used to perform leader election. Only used if leader election is enabled (default "kube-system")
  })]
}
