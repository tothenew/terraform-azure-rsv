data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

data "azurerm_virtual_machine" "vm" {
  for_each            = local.virtual_machines

  name                = each.value.vm.name
  resource_group_name = each.value.vm.resource_group_name != "" ? each.value.vm.resource_group_name : local.resource_group_name
}

data "azurerm_storage_account" "storage_backup" {
  for_each            = local.file_shares

  name                = each.value.file_share.storage_account_name
  resource_group_name = each.value.file_share.resource_group_name
}

