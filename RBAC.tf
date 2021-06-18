

data "azuread_user" "aaduser" {
  for_each            = toset(var.avdusers)
  user_principal_name = format("%s", each.key)
}

data "azurerm_role_definition" "role" { # access an existing builtin role
  name = "Desktop Virtualization User"
}

data "azurerm_client_config" "example" {
}

resource "azuread_group" "aadgroup" {
    display_name = "WVD Users1"
 }

resource "azuread_group_member" "aadgroupmember" {
  for_each         = data.azuread_user.aaduser
  group_object_id  = azuread_group.aadgroup.id
  member_object_id = each.value["id"]
}

resource "azurerm_role_assignment" "role" {
  scope              = azurerm_virtual_desktop_application_group.remoteapp.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = azuread_group.aadgroup.id
}
