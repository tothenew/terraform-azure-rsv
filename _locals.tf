locals { 
  name                = var.name == "" ? "-backup" : "-${var.name}"
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  resource_prefix     = var.resource_prefix == "" ? local.resource_group_name : var.resource_prefix
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  common_tags         = length(var.common_tags) == 0 ? var.default_tags : merge(var.default_tags, var.common_tags)

  virtual_machines = { 
    for idx, vm in var.backup_virtual_machines : vm.name => {
       idx : idx,
       vm : vm,
    }
  }

  file_shares = {
    for idx, fs in var.backup_file_shares : fs.name => {
      idx : idx
      file_share : fs
    }
  }

  timeout_create  = "180m"
  timeout_delete  = "60m"
  timeout_read    = "60m"
}