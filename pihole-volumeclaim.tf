resource "kubernetes_persistent_volume_claim" "pihole-volume" {
  metadata {
    name = "pihole-volume-claim"
    namespace = var.pihole_namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "tailscale-state-volume" {
  metadata {
    name = "tailscale-state-volume-claim"
    namespace = var.pihole_namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}