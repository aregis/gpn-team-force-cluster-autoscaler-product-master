locals {
  configs = yamldecode(file("../configs/cluster-autoscaler-values.yaml"))
}
