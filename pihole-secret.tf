resource "kubernetes_secret" "pihole-webpassword" {
  metadata {
    name = "pihole-secret-webpassword"
    namespace = var.pihole_namespace
  }
  data = {
    WEBPASSWORD = var.pihole_secret_WEBPASSWORD
  }
  type = "Opaque"
}

resource "kubernetes_secret" "tailscale-auth" {
  metadata {
    name = "tailscale-secret-auth"
    namespace = var.pihole_namespace
  }
  data = {
    TAILSCALE_AUTH = var.tailscale_secret_TAILSCALE_AUTH
  }
  type = "Opaque"
}