#Directory = /itom-tfe/sharedworkspace::main
#File1 = disk.tf

#File =disk.tf
variable "clientId" {}
variable "subscriptionId" {}
variable "tenantId" {}
variable "secretKey" {}

provider "azurerm" {
  version = "=2.4.0"
  client_id = var.clientId
  subscription_id = var.subscriptionId
  tenant_id = var.tenantId
  client_secret = var.secretKey
  features {}
}


variable "rgName" {
  type = map(string)
  default = {env = "test"}
}
variable "region" {}
variable "thirdDiskName" {
  type = string	
}

variable "thirdDiskSize" {
  type = number	
}

variable "tagged" {
  type = bool
  default = true
}

resource "azurerm_resource_group" "example" {
  name     = var.rgName["env"]
  location = var.region
}

variable "storage_disk" {
  type        = map(any)
  description = "Map of disk sizes in GB & caching mode for all disks this VM will need. Must look like this: {disk0 = { size = 64, caching ='ReadWrite', type = 'Premium_LRS'}}"
  default = {
    data0  = { size = "128", caching = "None", type = "Premium_LRS" },
    data1  = { size = "128", caching = "None", type = "Premium_LRS" },
    shared = { size = "128", caching = "None", type = "Premium_LRS" },
    log    = { size = "128", caching = "None", type = "Premium_LRS" },
    swap   = { size = "128", caching = "None", type = "Premium_LRS" }
  }
}

variable "firstDiskAttribute" {
	type = tuple([string, number])
	default = ["rgtest1", 1]
}

variable "secondDiskAttribute" {
	type = tuple([string, number])
	default = ["rgTest2", 2]
}

resource "azurerm_managed_disk" "example" {
  name                 = var.firstDiskAttribute[0]
  location             = var.region
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.firstDiskAttribute[1]

  tags = var.storage_disk["data0"]
}

resource "azurerm_managed_disk" "example2" {
  name                 = var.secondDiskAttribute[0]
  location             = var.region
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.secondDiskAttribute[1]

  tags = var.storage_disk["data1"]
}

resource "azurerm_managed_disk" "example3" {
  name                 = var.thirdDiskName
  location             = var.region
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.thirdDiskSize

  tags = {
    tagged = var.tagged
  }
}
