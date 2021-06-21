
resource "azurerm_subnet" "netApp_subnet" {
  name                 = var.NetApp_subnet_name
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.VNet.name
  address_prefixes     = ["10.4.1.0/24"]
  
}


resource "azurerm_netapp_account" "NetApp_acct" {
  name                = var.NetApp_acct_name
  resource_group_name = var.rgname
  location            = var.deploylocation

  active_directory {
    username            = var.domain_user_upn
    password            = var.domain_password
    smb_server_name     = var.NetApp_smb_name
    dns_servers         = ["10.0.0.4","168.63.129.16"]
    domain              = var.domain_name
    organizational_unit = var.ou_path
  }
  depends_on = [azurerm_resource_group.resourcegroup]
}

resource "azurerm_netapp_pool" "NetApp_pool" {
  name                = var.NetApp_pool_name
  location            = var.deploylocation
  resource_group_name = var.rgname
  account_name        = var.NetApp_acct_name
  service_level       = "Standard"
  size_in_tb          = 4

  depends_on = [azurerm_resource_group.resourcegroup, azurerm_netapp_account.NetApp_acct]
}

resource "azurerm_netapp_volume" "NetApp_Vol" {
  lifecycle {
    prevent_destroy = true
  }

  name                = var.NetApp_volume_name
  location            = var.deploylocation
  resource_group_name = var.rgname
  account_name        = var.NetApp_acct_name
  pool_name           = var.NetApp_pool_name
  volume_path         = var.NetApp_volume_path
  service_level       = "Standard"
  subnet_id           = azurerm_subnet.netApp_subnet.id
  protocols           = ["CIFS"]
  storage_quota_in_gb = 100

 depends_on = [azurerm_netapp_pool.NetApp_pool]

}
