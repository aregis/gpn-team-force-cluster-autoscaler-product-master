provider "aws" { 
  region = local.configs.global.region
}

provider "kubernetes" {
 config_path = "~/.kube/config"
}

