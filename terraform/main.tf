data "aws_region" "current" {}

locals {
  mod_dependency = local.configs.K8s.mod_dependency
}


resource "kubernetes_namespace" "cluster_autoscaler" {
  depends_on = [local.dependency]
  count      = (local.configs.cluster.enabled && local.configs.K8s.k8s_namespace != "kube-system") ? 1 : 0

  metadata {
    name = local.configs.K8s.k8s_namespace
  }
}



resource "helm_release" "cluster_autoscaler" {
  depends_on = [local.mod_dependency]
  count      = local.configs.cluster.enabled ? 1 : 0
  chart      = local.configs.helm.helm_chart_name
  namespace  = local.configs.K8s.k8s_namespace
  name       = local.configs.helm.helm_release_name
  version    = local.configs.helm.helm_chart_version
  repository = local.configs.helm.helm_repo_url

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = local.configs.cluster.name
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = local.configs.K8s.k8s_service_account_name
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler[0].arn
  }

  dynamic "set" {
    for_each = local.configs.K8s.settings
    content {
      name  = set.key
      value = set.value
    }
  }
}
