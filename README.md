# Azure Backup Terraform module

[![Lint Status](https://github.com/tothenew/terraform-azure-rsv/workflows/Lint/badge.svg)](https://github.com/tothenew/terraform-azure-rsv/actions)
[![LICENSE](https://img.shields.io/github/license/tothenew/terraform-azure-rsv)](https://github.com/tothenew/terraform-azure-rsv/blob/master/LICENSE)

Take advantage of fully managed backup of virtual machines and storage accounts in the cloud.

Azure Backup provides independent and isolated backups to guard against unintended destruction of the data on your VMs. Backups are stored in a Recovery Services vault with built-in management of recovery points. Configuration and scaling are simple, backups are optimized, and you can easily restore as needed.

# Workflow of this module

Two child modules, storage-backup and vm-backup, are located in the example folder of this module. Therefore, you must execute only storage-backup if you only want to create storage account backups, and you must run the vm-backup module in the example folder if you only want to produce VM backups.

## vm-backup module 

```hcl
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "azure-backup" {
	source  = "../../"

	# Name of the azure file sync instance (default "backup")
	name = "backup" 

	create_resource_group = false 

	resource_group_name = "Deepak"

	location = "Central India"

	# (Optional) Prefix to use for all resoruces created (Defaults to resource_group_name)
	resource_prefix = "vm-backup"

	# (Optional) Indicates the name of recovery services vault to be created
	recovery_services_vault_name = "rsv"

    # (Optional) Indicates the sku for the recovery services value to use during creation
	recovery_services_vault_sku = "Standard"

    # (Optional) Indicates which version type to use when creating the backup policy
	backup_policy_type = "V1"

	# (Optional) Indicate the fequency to use for the backup policy
	backup_policy_frequency = "Daily"

	# (Optional) Indicates the time for when to execute the backup policy
	backup_policy_time = "23:00"

	# (Optional) Indicates the number of daily backups to retain (set to blank to disable)
	backup_policy_retention_daily_count = 7

	# (Optional) Indicates the number of weekly backups to retain (set to blank to disable)
	backup_polcy_retention_weekly_count = 4

	# (Optional) Indicates the number of monthly backups to retain (set to blank to disable)
	backup_polcy_retention_monthly_count = 6

	create_vm_backup = true 

	backup_virtual_machines = [
    {
      name                = "demovm"
      resource_group_name = "Deepak"
      os_type             = "Linux"
    }
  ]
}

```

## storage-backup module

```hcl
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "azure-backup" {
	source  = "../../"

	# Name of the azure file sync instance (default "backup")
	name = "backup" 

	create_resource_group = false 

	resource_group_name = "Deepak"

	location = "Central India"

	# (Optional) Prefix to use for all resoruces created (Defaults to resource_group_name)
	resource_prefix = "storage-backup"

	# (Optional) Indicates the name of recovery services vault to be created
	recovery_services_vault_name = "rsv"

    # (Optional) Indicates the sku for the recovery services value to use during creation
	recovery_services_vault_sku = "Standard"

	# (Optional) Indicate the fequency to use for the backup policy
	backup_policy_frequency = "Daily"

	# (Optional) Indicates the time for when to execute the backup policy
	backup_policy_time = "23:00"

	# (Optional) Indicates the number of daily backups to retain (set to blank to disable)
	backup_policy_retention_daily_count = 7

	# (Optional) Indicates the number of weekly backups to retain (set to blank to disable)
	backup_polcy_retention_weekly_count = 4

	# (Optional) Indicates the number of monthly backups to retain (set to blank to disable)
	backup_polcy_retention_monthly_count = 6

	create_file_share_backup = true 

	backup_file_shares = [
    {
      name                  = "demotesting01b3bb"
      resource_group_name   = "Deepak"
      storage_account_name  = "deepak8754" 
    }
  ]
}

```


## Create resource group

By default, this module will create a resource group and the name of the resource group to be given in an argument `resource_group_name`. If you want to use an existing resource group, specify the existing resource group name, and set the argument to `create_resource_group = false`.

> *If you are using an existing resource group, then this module uses the same resource group location to create all resources in this module.*

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [azurerm](#requirement\_terraform) | >= 3.39.0 |

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`name` | Name of the azure file storage instance | `string` | `filestorage`
`create_resource_group` | Whether to create resource group and use it for all networking resources | `boolean` | `true`
`resource_group_name` | A container that holds related resources for an Azure solution | `string` | `rg-filestorage`
`location` | The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table' | `string` | `eastus2`
`resource_prefix` | (Optional) Prefix to use for all resoruces created (Defaults to resource_group_name) | `string` | ``
`recovery_services_vault_name` | (Optional) Indicates the name of recovery services vault to be created | `string` | ``
`recovery_services_vault_sku` | (Optional) Indicates the sku for the recovery services value to use during creation | `string` | `Standard`
`backup_policy_type` | (Optional) Indicates which version type to use when creating the backup policy | `string` | `V2`
`backup_policy_frequency` | (Optional) Indicate the fequency to use for the backup policy | `string` | `Daily`
`backup_policy_time` | (Optional) Indicates the time for when to execute the backup policy | `string` | `23:00`
`backup_policy_retention_daily_count` | (Optional) Indicates the number of daily backups to retain (set to blank to disable) | `string` | `7`
`backup_polcy_retention_weekly_count` | (Optional) Indicates the number of weekly backups to retain (set to blank to disable) | `string` | `4`
`backup_policy_retention_weekly_weekdays` | (Optional) Indicates which days of the week the monthly backup will be taken | `set(string)` | `[ "Saturday" ]`
`backup_polcy_retention_monthly_count` | (Optional) Indicates the number of monthly backups to retain (set to blank to disable) | `string` | `6`
`backup_policy_retention_monthly_weekdays` | (Optional) Indicates which days of the week the monthly backup will be taken | `set(string)` | `[ "Saturday" ]`
`default_tags` | A map of default tags to add to all resources | `map(string)` | `{}`
`common_tags` | A map of common tags to add to all resources | `map(string)` | `{}`

## Outputs

Name | Description
---- | -----------
`resource_group_name` | The name of the resource group in which resources are created
`resource_group_id` | The id of the resource group in which resources are created
`resource_group_location` | The location of the resource group in which resources are created
`azurerm_backup_policy_vm_id` | The id of the backup policy
`azurerm_backup_protected_vm_id` | The id of the backup protected vm resource
`azurerm_recovery_services_vault_id` | The id of the recover services vault
`azurerm_recovery_services_vault_name` | The name of the recover services vault
`azurerm_backup_protected_vm_ids` | The id of the backup protected vm



## Authors

Module managed by [TO THE NEW Pvt. Ltd.](https://github.com/tothenew)


## License

Apache 2 Licensed. See [LICENSE](https://github.com/tothenew/terraform-azure-rsv/blob/main/LICENSE) for full details.



## Other resources

* [Azure Backup](https://azure.microsoft.com/en-us/products/backup/#overview)
* [Terraform AzureRM Provider Documentation](https://www.terraform.io/docs/providers/azurerm/index.html)