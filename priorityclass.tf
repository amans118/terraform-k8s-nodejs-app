# create priority class for deployment
resource "kubernetes_priority_class" "high-priority-nonpreemptive" {
  metadata {
    name = "high-priority-nonpreemptive"
  }
  global_default = false
  value          = 10000000
}
