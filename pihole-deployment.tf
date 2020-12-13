resource "kubernetes_deployment" "pihole" {
  metadata {
    name = var.pihole_app_name
    labels = {
      app = var.pihole_app_name
    }
    namespace = var.pihole_namespace
  }

  spec {
    replicas = var.pihole_replicas
    selector {
      match_labels = {
        app = var.pihole_app_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.pihole_app_name
        }
      }
      spec {
        container {
          image = var.pihole_container_image
          name  = var.pihole_container_name

          port {
            container_port = 80
            name           = "http"
            protocol       = "TCP"
          }
          port {
            container_port = 443
            name           = "https"
            protocol       = "TCP"
          }
          port {
            container_port = 53
            name           = "dns-udp"
            protocol       = "UDP"
          }
          port {
            container_port = 67
            name           = "dns67"
            protocol       = "UDP"
          }

          env {
            name  = "TZ"
            value = var.pihole_env_TZ
          }
          env {
            name  = "WEBPASSWORD"
            value_from {
              secret_key_ref {
                name = "pihole-secret-webpassword"
                key = "WEBPASSWORD"
              }
            }
          }
          env {
            name  = "DNS1"
            value = var.pihole_env_DNS1
          }
          env {
            name  = "DNS2"
            value = var.pihole_env_DNS2
          }
          env {
            name  = "DNSMASQ_LISTENING"
            value = "all"
          }
          env {
            name = "PIHOLE_BASE"
            value = "/opt/pihole-volume"
          }

          resources {
            limits {
              cpu    = "250m"
              memory = "896Mi"
            }
            requests {
              cpu    = "20m"
              memory = "512Mi"
            }
          }

          volume_mount {
            name = "pihole-volume"
            mount_path = "/opt/pihole-volume"
          }

          volume_mount {
            name = "regex"
            mount_path = "/etc/pihole/regex.list"
            sub_path = "regex.list"
          }
          volume_mount {
            name = "adlists"
            mount_path = "/etc/pihole/adlists.list"
            sub_path = "adlists.list"
          }
          volume_mount {
            name = "whitelist"
            mount_path = "/etc/pihole/whitelist.txt"
            sub_path = "whitelist.txt"
          }
        }

        container {
          image = var.tailscale_container_image
          name  = var.tailscale_container_name

          security_context {
            capabilities {
              add = ["NET_ADMIN"]
            }
          }

          env {
            name = "TAILSCALE_AUTH"
            value_from {
              secret_key_ref {
                name = "tailscale-secret-auth"
                key = "TAILSCALE_AUTH"
              }
            }
          }
          env {
            name = "TAILSCALE_TAGS"
            value = "tag:test-container"
          }
          
          resources {
            limits {
              cpu    = "250m"
              memory = "512Mi"
            }
            requests {
              cpu    = "20m"
              memory = "64Mi"
            }
          }

          volume_mount {
            name = "tailscale-state-volume"
            mount_path = "/tailscale"
          }

        }

        volume {
          name = "pihole-volume"
          persistent_volume_claim {
            claim_name = "pihole-volume-claim"
          }
        }

        volume {
          name = "regex"
          config_map {
            name = "regex.list"
          }
        }
        volume {
          name = "adlists"
          config_map {
            name = "adlists.list"
          }
        } 
        volume {
          name = "whitelist"
          config_map {
            name = "whitelist.txt"
          }
        } 

        volume {
          name = "tailscale-state-volume"
          persistent_volume_claim {
            claim_name = "tailscale-state-volume-claim"
          }
        }
      }
    }
  }
}