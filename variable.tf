variable "subscription_id" {
  type    = string
  default = "8dacc1dd-f4ac-4194-a38f-8d4b6e81427a"
}

variable "resource_group_name" {
  type    = string
  default = "terraform-resource-group"
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

variable "azure_public_ip_sku"{
    type = string
    default = "Standard"
}

variable "kubernetes_version" {
  type    = string
  default = "1.24.9" # default version as per March 2023
}

variable "sku_tier" {
  type    = string
  default = "Free"
}