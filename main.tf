terraform {
  required_version = ">=0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.47.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id            = "8dacc1dd-f4ac-4194-a38f-8d4b6e81427a" # Vignesh Azure subscription(Free Tier)
  skip_provider_registration = true
}


# resource "azurerm_resource_group" "terraform-aks-managed-rg" {
#   name     = "terraform-aks-managed-rg"
#   location = var.location
# }

module "vnet" {
  source = "./modules/vnet"

  location            = var.location
  resource_group_name = var.resource_group_name
  azure_public_ip_sku = var.azure_public_ip_sku
}


resource "azurerm_public_ip_prefix" "example" {
  name                = "acceptanceTestPublicIpPrefix1"
  location            = var.location
  resource_group_name = var.resource_group_name

  prefix_length = 28

  tags = {
    environment = "Dev"
  }
}

###########-----------Azure AKS--------------############
resource "azurerm_kubernetes_cluster" "example" {
  name                    = "example-aks1"
  location                = var.location
  resource_group_name     = var.resource_group_name
  kubernetes_version      = var.kubernetes_version
  dns_prefix              = "rx4demo"
  sku_tier                = var.sku_tier
  private_cluster_enabled = false
  node_resource_group     = "terraform-aks-managed-rg"

  api_server_access_profile {
    authorized_ip_ranges = ["120.72.93.91/32", "10.224.0.0/12"]
  }

  linux_profile {
    ssh_key {
      key_data = file("~/.ssh/id_rsa.pub")
    }
    admin_username = "rx4"
  }

  default_node_pool {
    name                  = "default"
    zones                 = [var.zone_1, var.zone_2, var.zone_3]
    node_count            = 1
    min_count             = 1
    max_count             = 2
    vm_size               = "Standard_D2_v2"
    enable_auto_scaling   = true
    enable_node_public_ip = true
    # vnet_subnet_id           = azurerm_subnet.public2.id
    os_disk_size_gb          = 30
    node_public_ip_prefix_id = azurerm_public_ip_prefix.example.id
  }

  ingress_application_gateway {
    gateway_name = "rx4-ingress"
    # subnet_id    = azurerm_subnet.rx4-ingress-subnet.id
    subnet_cidr = "10.225.0.0/16"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}
