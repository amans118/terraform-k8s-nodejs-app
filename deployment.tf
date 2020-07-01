# create a deployment for the nodejs-app
resource "kubernetes_deployment" "nodejs-app" {
  metadata {
    name = "nodejs-app"
    labels = {
      app = "nodejs-app"
    }
  }

  spec {
    replicas = 10

    selector {
      match_labels = {
        app = "nodejs-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "nodejs-app"
        }
      }

      spec {
        image_pull_secrets {
          name = "docker-key"
        }
        priority_class_name = "high-priority-nonpreemptive"
        container {
          image = "647833373684.dkr.ecr.ap-southeast-1.amazonaws.com/nodejs-test:latest"
          name  = "nodejs-test"

          resources {
            limits {
              cpu    = "400m"
              memory = "128Mi"
            }
            requests {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
          port {
            name           = "http"
            container_port = 3000
            protocol       = "TCP"
          }
        }
      }
    }
  }
}
