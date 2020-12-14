resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${random_pet.prefix.id}-rg"
  location = var.aks_location
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = var.aks_node_pool_node_count
    vm_size         = var.aks_node_pool_vm_size
    os_disk_size_gb = var.aks_node_pool_os_disk_size_gb
  }

  service_principal {
    client_id     = var.aks_service_principal_app_id
    client_secret = var.aks_service_principal_password
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }
}
