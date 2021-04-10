locals {
  dependency = local.configs.K8s.mod_dependency
}

# Policy
data "aws_iam_policy_document" "cluster_autoscaler" {
  count = local.configs.cluster.enabled ? 1 : 0

  statement {
    sid = "Autoscaling"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

}

resource "aws_iam_policy" "cluster_autoscaler" {
  depends_on  = [local.dependency]
  count       = local.configs.cluster.enabled ? 1 : 0
  name        = "${local.configs.iam.policy_name}"
  path        = "/"
  description = "Policy for cluster-autoscaler service"

  policy = data.aws_iam_policy_document.cluster_autoscaler[0].json
}

# Role
data "aws_iam_policy_document" "cluster_autoscaler_assume" {
  count = local.configs.cluster.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.configs.oidc.cluster_identity_oidc_issuer_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(local.configs.oidc.cluster_identity_oidc_issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${local.configs.K8s.k8s_namespace}:${local.configs.K8s.k8s_service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  depends_on         = [local.dependency]
  count              = local.configs.cluster.enabled ? 1 : 0
  name               = "${local.configs.cluster.name}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume[0].json
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  depends_on = [local.dependency]
  count      = local.configs.cluster.enabled ? 1 : 0
  role       = aws_iam_role.cluster_autoscaler[0].name
  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
}
