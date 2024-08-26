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