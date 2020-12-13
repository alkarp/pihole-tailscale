resource "kubernetes_service" "service-udp" {
  count = var.pihole_externally_available ? 1 : 0
  
  metadata {
    name      = "${var.pihole_app_name}-udp"
    namespace = var.pihole_namespace
  }
  spec {
    selector = {
      app = var.pihole_app_name
    }
    session_affinity = "ClientIP"
    
    port {
      protocol    = "UDP"
      port        = 53
      target_port = 53
      name        = "dns-udp"
    }

    type = "LoadBalancer"
  }
}