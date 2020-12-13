resource "kubernetes_namespace" "pihole" {
  metadata {
    annotations = {
      name = var.pihole_app_name
    }

    labels = {
      app = var.pihole_app_name
    }

    name = var.pihole_namespace
  }
}
