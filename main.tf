resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location

  tags = merge(local.common_tags, tomap({
    "Env" : "Dev"
  }))
}

#-------------------------------------
## Recovery Services
#-------------------------------------

resource "azurerm_recovery_services_vault" "vault" {
  name                = var.recovery_services_vault_name != "" ? var.recovery_services_vault_name : "${local.resource_prefix}-bvault"
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = var.recovery_services_vault_sku != null ? var.recovery_services_vault_sku : "Standard"
  storage_mode_type   = var.recovery_services_vault_storage_mode != null ? var.recovery_services_vault_storage_mode : "LocallyRedundant"
  
  #cross_region_restore_enabled = var.recovery_servuces_vault_cross_region_restore_enabled

  tags = merge(local.common_tags, tomap({
    "Env" : "Dev"
  })) 
}


#-------------------------------------
## Backup Policy
#-------------------------------------

resource "azurerm_backup_policy_vm" "policy" {
  count               = var.create_vm_backup ? 1 : 0
  name                = "${local.resource_prefix}-bkpool-vms"
  resource_group_name = local.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  policy_type         = var.backup_policy_type != null ? var.backup_policy_type : "V2"

  timezone = var.backup_policy_time_zone != null ? var.backup_policy_time_zone : "UTC"

  backup {
    frequency = var.backup_policy_frequency != null ? var.backup_policy_frequency : "Daily"
    time      = var.backup_policy_time != null ? var.backup_policy_time : "23:00"
  }

  dynamic "retention_daily" {
    for_each = var.backup_policy_retention_daily_count != "" ? [1] : []

    content {
      count = var.backup_policy_retention_daily_count
    }
  }

  dynamic "retention_weekly" {
    for_each = var.backup_polcy_retention_weekly_count != "" ? [1] : []

    content {
      count = var.backup_polcy_retention_weekly_count
      weekdays = var.backup_policy_retention_weekly_weekdays != null ? var.backup_policy_retention_weekly_weekdays : [ "Saturday" ]
    }
  }

  dynamic "retention_monthly" {
    for_each = var.backup_polcy_retention_monthly_count != "" ? [1] : []

    content {
      count = var.backup_polcy_retention_monthly_count
      weekdays  = var.backup_policy_retention_monthly_weekdays != null ? var.backup_policy_retention_monthly_weekdays : [ "Saturday" ]
      weeks     = [ "Last" ]
    }
  }  
}

resource "azurerm_backup_policy_file_share" "policy" {
  count               = var.create_file_share_backup ? 1 : 0
  name                = "${local.resource_prefix}-bkpool-fileshares"
  resource_group_name = local.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = var.backup_policy_time_zone != null ? var.backup_policy_time_zone : "UTC"

  backup {
    frequency = var.backup_policy_frequency != null ? var.backup_policy_frequency : "Daily"
    time      = var.backup_policy_time != null ? var.backup_policy_time : "23:00"
  }

  dynamic "retention_daily" {
    for_each = var.backup_policy_retention_daily_count != "" ? [1] : []

    content {
      count = var.backup_policy_retention_daily_count
    }
  }

  dynamic "retention_weekly" {
    for_each = var.backup_polcy_retention_weekly_count != "" ? [1] : []

    content {
      count = var.backup_polcy_retention_weekly_count
      weekdays = var.backup_policy_retention_weekly_weekdays != null ? var.backup_policy_retention_weekly_weekdays : [ "Saturday" ]
    }
  }

  dynamic "retention_monthly" {
    for_each = var.backup_polcy_retention_monthly_count != "" ? [1] : []

    content {
      count = var.backup_polcy_retention_monthly_count
      weekdays  = var.backup_policy_retention_monthly_weekdays != null ? var.backup_policy_retention_monthly_weekdays : [ "Saturday" ]
      weeks     = [ "Last" ]
    }
  }  
}


#-------------------------------------
## Enable Backups for VMs
#-------------------------------------
resource "azurerm_backup_protected_vm" "vm" {
  for_each            = var.create_vm_backup ? local.virtual_machines : {}

  resource_group_name = local.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  backup_policy_id    = azurerm_backup_policy_vm.policy[0].id 

  source_vm_id        = data.azurerm_virtual_machine.vm[each.value.vm.name].id
}

#-------------------------------------
## Enable Backups for File Shares
#-------------------------------------
resource "azurerm_backup_container_storage_account" "container" {
  for_each            = var.create_file_share_backup ? local.file_shares : {}

  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  resource_group_name = local.resource_group_name

  storage_account_id  = data.azurerm_storage_account.storage_backup[each.value.file_share.name].id

  depends_on = [
    data.azurerm_storage_account.storage_backup
  ]  
}

resource "azurerm_backup_protected_file_share" "share" {
  for_each            = var.create_file_share_backup ? local.file_shares : {}

  resource_group_name = local.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  backup_policy_id    = azurerm_backup_policy_file_share.policy[0].id

  source_storage_account_id = data.azurerm_storage_account.storage_backup[each.value.file_share.name].id
  source_file_share_name    = each.value.file_share.name

  depends_on = [
    azurerm_backup_container_storage_account.container
  ]
}