# create a service to expose the deployment
resource "kubernetes_service" "nodejs-app" {
  metadata {
    name = "nodejs-app"
  }
  spec {
    selector = {
      app = "nodejs-app"
    }
    port {
      port        = 3000
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}
