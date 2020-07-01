# deploying metrics server using metrics-server module.
# https://registry.terraform.io/modules/cookielab/metrics-server/kubernetes/
# https://github.com/cookielab/terraform-kubernetes-metrics-server
module "metrics_server" {
  source                                     = "cookielab/metrics-server/kubernetes"
  version                                    = "0.10.0"
  metrics_server_option_kubelet_insecure_tls = "true"
}

# create HPA for autoscaling of pods.
resource "kubernetes_horizontal_pod_autoscaler" "nodejs-app" {
  metadata {
    name = "nodejs-app"
  }

  spec {
    min_replicas = 7
    max_replicas = 10

    scale_target_ref {
      kind        = "Deployment"
      name        = "nodejs-app"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 60
        }
      }
    }
  }
}
