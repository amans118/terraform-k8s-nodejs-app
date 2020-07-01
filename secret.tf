# create secret to be used by deployment for pulling image from private registry
# https://www.terraform.io/docs/providers/kubernetes/r/secret.html
resource "kubernetes_secret" "docker-key" {
  metadata {
    name = "docker-key"
  }

  data = {
    ".dockerconfigjson" = "${file("${path.module}/.docker/config.json")}"
  }

  type = "kubernetes.io/dockerconfigjson"
}
