# cluster vars

variable "service_principal_app_id" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "service_principal_password" {
  description = "Azure Kubernetes Service Cluster password"
}

# pihole deployment vars

variable "pihole_namespace" {
  description = "namespace"
  default     = "pihole"
}

variable "pihole_app_name" {
  description = "service name"
  default     = "pihole"
}

variable "pihole_replicas" {
  description = "number of replicas"
  default     = "1"
}

variable "pihole_container_image" {
  description = "container image name"
  default     = "pihole/pihole:latest"
}

variable "pihole_container_name" {
  description = "container name"
  default     = "pihole"
}

variable "pihole_env_TZ" {
  description = "time zone"
  default     = "Europe/London"
}

variable "pihole_secret_WEBPASSWORD" {
  description = "web ui password"
}

variable "pihole_env_DNS1" {
  description = "upstream DNS1"
  default     = "1.1.1.1"
}

variable "pihole_env_DNS2" {
  description = "upstream DNS2"
  default     = "1.0.0.1"
}

variable "pihole_externally_available" {
  description = "expose DNS resolver externally"
  default = false
}

# pihole configmaps

variable "pihole_regex_list_content" {
  description = "regex list"
  default     = <<EOF
(^|\.)tiktok\.com$
    EOF
}

variable "pihole_adlists_list_content" {
  description = "blocks list"
  default     = <<EOF
https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/android-tracking.txt
https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt
    EOF
}

variable "pihole_whitelist_list_content" {
  description = "whitelist lis"
  default     = <<EOF
bbc.co.uk
    EOF
}

# tailscale deployment vars

variable "tailscale_container_image" {
  description = "container image name"
  default     = "alkarp/tailscale:1.2.10"
}

variable "tailscale_container_name" {
  description = "container name"
  default     = "tailscale"
}

variable "tailscale_secret_TAILSCALE_AUTH" {
  description = "authentication secret"
}