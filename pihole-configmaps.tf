resource "kubernetes_config_map" "pihole_regex_list" {
  metadata {
    name      = "regex.list"
    namespace = var.pihole_namespace
  }

  data = {
    "regex.list" =var.pihole_regex_list_content
  }
}

resource "kubernetes_config_map" "pihole_adlists_list" {
  metadata {
    name      = "adlists.list"
    namespace = var.pihole_namespace
  }

  data = {
    "adlists.list" = var.pihole_adlists_list_content
  }
}

resource "kubernetes_config_map" "pihole_whitelist_list" {
  metadata {
    name      = "whitelist.txt"
    namespace = var.pihole_namespace
  }

  data = {
    "adlists.list" = var.pihole_whitelist_list_content
  }
}