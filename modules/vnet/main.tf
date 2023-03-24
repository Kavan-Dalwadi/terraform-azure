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
  name                = "my-network"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.224.0.0/12"]
  dns_servers         = ["10.224.0.2", "10.224.0.3"]

  tags = {
    environment = "Dev"
  }
}

#############---------------Private-Subnet-1------------------_################
resource "azurerm_subnet" "private1" {
  name                 = "private-subnet1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

#############---------------Private-Subnet-2 ------------------_################
resource "azurerm_subnet" "private2" {
  name                 = "private-subnet2"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/24"]
}

#############---------------Public Subnet-1------------------_################
resource "azurerm_subnet" "public1" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.224.0.0/16"]
}
resource "azurerm_route_table" "public1" {
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
  subnet_id      = azurerm_subnet.public1.id
  route_table_id = azurerm_route_table.public1.id
}

#############---------------Public Subnet-2 ------------------_################
resource "azurerm_subnet" "public2" {
  name                 = "rx4-ingress-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.225.0.0/16"]
}

resource "azurerm_route_table" "public2" {
  name                          = "rx4-ingress-rt"
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

resource "azurerm_subnet_route_table_association" "public2" {
  subnet_id      = azurerm_subnet.public2.id
  route_table_id = azurerm_route_table.public2.id
}

resource "azurerm_public_ip" "example" {
  name                = "examplepip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = var.azure_public_ip_sku
  tags = {
    environment = "Dev"
  }
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
#     tags = {
#     environment = "Dev"
#   }
# }
