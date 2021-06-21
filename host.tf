#----------------------------------
# Session Host VM
#----------------------------------
locals {
  registration_token = azurerm_virtual_desktop_host_pool.HP.registration_info[0].token
}



#generate the random local machine pw
resource "random_string" "avd-local-password" {
  count            = "${var.rdsh_count}"
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}


# Create a NIC for the Session Host VM
resource "azurerm_network_interface" "avd_vm_nic" {
  count                     = "${var.rdsh_count}"
  name                      = "${var.vm_prefix}-${count.index +1}-nic"
  resource_group_name       = var.rgname
  location                  = var.deploylocation

  ip_configuration {
    name                          = "nic${count.index +1}_config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

# Create the Session Host VM
resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = "${var.rdsh_count}"
  name                  = "${var.vm_prefix}-${count.index + 1}"
  resource_group_name   = var.rgname
  location              = var.deploylocation
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent    = true
    admin_username = "${var.local_admin_username}"
    admin_password = "${random_string.avd-local-password.*.result[count.index]}"
  
  os_disk {
    name                 = "${lower(var.vm_prefix)}-${count.index +1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"                                 # This is the Windows 10 Enterprise Multi-Session image
    version   = "latest"
  }
}

# VM Extension for Domain-join
resource "azurerm_virtual_machine_extension" "domain_join" {
  count                 = "${var.rdsh_count}"
  name                       = "${var.vm_prefix}-${count.index +1}-domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "Name": "${var.domain_name}",
        "OUPath": "${var.ou_path}",
        "User": "${var.domain_user_upn}@${var.domain_name}",
        "Restart": "true",
        "Options": "3"
    }
    SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
         "Password": "${var.domain_password}"
  }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [ settings, protected_settings ]
  }
  depends_on = [ azurerm_virtual_network_peering.peer1, azurerm_virtual_network_peering.peer2 ]

}

# VM Extension for Desired State Config
resource "azurerm_virtual_machine_extension" "vmext_dsc" {
    count                 = "${var.rdsh_count}"
  name                       = "${var.vm_prefix}${count.index +1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true
  
  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_3-10-2021.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
      "HostPoolName":"${azurerm_virtual_desktop_host_pool.HP.name}"
      
      }
    }
    SETTINGS
    
protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
         
  }
PROTECTED_SETTINGS



  depends_on = [ azurerm_virtual_machine_extension.domain_join, azurerm_virtual_desktop_host_pool.HP ]
}
