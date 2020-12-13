resource "kubernetes_ingress" "pihole_ingress" {
  metadata {
    name      = var.pihole_app_name
    namespace = var.pihole_namespace
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = "${var.pihole_app_name}-tcp"
            service_port = 80
          }
          path = "/admin"
        }
      }
    }
  }
}