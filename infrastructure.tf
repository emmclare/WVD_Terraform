resource "time_rotating" "wvd_token" {
  rotation_days = 30
}

# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
  required_version = ">= 0.14.9"
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = var.rgname
  location = var.deploylocation
}

resource "azurerm_virtual_network" "VNet" {
    name                = "WVD-TF-VNet"
    address_space       = ["10.1.0.0/16"]
    dns_servers         = ["10.0.0.4","168.63.129.16"]
    location            = var.deploylocation
    resource_group_name = azurerm_resource_group.resourcegroup.name
    
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.VNet.name
  address_prefixes     = ["10.1.0.0/24"]
  
}

resource "azurerm_network_security_group" "NSG" {
  name                = "WVD-TF-NSG "
  location            = var.deploylocation
  resource_group_name = azurerm_resource_group.resourcegroup.name

  security_rule {
    name                       = "HTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}


resource "azurerm_virtual_network_peering" "peer1" {
  name                      = "peerwvdtftoad"
  resource_group_name       = azurerm_resource_group.resourcegroup.name
  virtual_network_name      = azurerm_virtual_network.VNet.name
  remote_virtual_network_id = var.adVnetID
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                      = "peeradtowvdtf"
  resource_group_name       = var.adRG
  virtual_network_name      = var.adVnet
  remote_virtual_network_id = azurerm_virtual_network.VNet.id
}

resource "azurerm_virtual_desktop_workspace" "WS" {
  name                = "workspace"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  friendly_name = "WVD TF Workspace"
  description   = "WVD TF Workspace"
}

resource "azurerm_virtual_desktop_host_pool" "HP" {
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  name                     = var.host_pool_name
  friendly_name            = var.host_pool_name
  validate_environment     = true
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
  description              = "WVD-TF-HP Terraform HostPool"
  type                     = "Pooled"
  maximum_sessions_allowed = 50
  load_balancer_type       = "DepthFirst"
  registration_info {
    expiration_date = time_rotating.wvd_token.rotation_rfc3339

  }
}

resource "azurerm_virtual_desktop_application_group" "remoteapp" {
  name                = "wvd-tf-remoteapp"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  type                = "RemoteApp"
  host_pool_id        = azurerm_virtual_desktop_host_pool.HP.id
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-ra" {
  workspace_id         = azurerm_virtual_desktop_workspace.WS.id
  application_group_id = azurerm_virtual_desktop_application_group.remoteapp.id
}

