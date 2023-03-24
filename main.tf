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

variable "subscription_id" {
  type    = string
  default = "8dacc1dd-f4ac-4194-a38f-8d4b6e81427a"
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "zone_1" {
  type    = number
  default = 1
}

variable "zone_2" {
  type    = number
  default = 2
}

variable "zone_3" {
  type    = number
  default = 3
}

variable "resource_group_name" {
  type    = string
  default = "terraform-resource-group"
}

variable "kubernetes_version" {
  type    = string
  default = "1.24.9" # default version as per March 2023
}

variable "sku_tier" {
  type    = string
  default = "Free"
}


# resource "azurerm_resource_group" "terraform-aks-managed-rg" {
#   name     = "terraform-aks-managed-rg"
#   location = "Central India"
# }

resource "azurerm_network_security_group" "demo1" {
  name                = "terraform"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "terraform123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "120.72.93.91/32"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.224.0.0/12"]
  dns_servers         = ["10.224.0.2", "10.224.0.3"]

  tags = {
    environment = "Dev"
  }
}

# resource "azurerm_subnet" "private1" {
#   name                 = "private-subnet1"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = ["10.0.1.0/24"]
# }


#############---------------Public Subnet-1------------------_################
resource "azurerm_subnet" "aks-subnet" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.224.0.0/16"]
}
resource "azurerm_route_table" "aks-subnet" {
  name                          = "aks-subnet-rt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name           = "internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  route {
    name           = "local"
    address_prefix = "10.224.0.0/12"
    next_hop_type  = "VnetLocal"
  }

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet_route_table_association" "public1" {
  subnet_id      = azurerm_subnet.aks-subnet.id
  route_table_id = azurerm_route_table.aks-subnet.id
}

#############---------------Private Subnet-2 ------------------_################
# resource "azurerm_subnet" "private2" {
#   name                 = "private-subnet2"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = ["10.0.3.0/24"]
# }


#############---------------Public Subnet-2 ------------------_################
resource "azurerm_subnet" "rx4-ingress-subnet" {
  name                 = "rx4-ingress-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.225.0.0/16"]
}

resource "azurerm_route_table" "rx4-ingress" {
  name                          = "rx4-ingress-rt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

  # route {
  #   name           = "internet"
  #   address_prefix = "0.0.0.0/0"
  #   next_hop_type  = "Internet"
  # }

  # route {
  #   name           = "local"
  #   address_prefix = "10.224.0.0/12"
  #   next_hop_type  = "VnetLocal"
  # }

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet_route_table_association" "public2" {
  subnet_id      = azurerm_subnet.rx4-ingress-subnet.id
  route_table_id = azurerm_route_table.rx4-ingress.id
}

resource "azurerm_public_ip" "example" {
  name                = "examplepip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# resource "azurerm_bastion_host" "example" {
#   name                = "examplebastion"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.public1.id
#     public_ip_address_id = azurerm_public_ip.example.id
#   }
# }


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