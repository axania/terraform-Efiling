# Configure the Azure Provider
provider "azurerm" {
  version         = ">= 2.0"
  features {}
}

#Environment variables to be used by the provisioner 
#change these ones for further servers/environments
variable "admin_username" {
  default = "efi"
}

variable "admin_password" {
  default = "S4b4d0@w0rk#01"
}

variable "environment_prefix" {
  default = "qa-sr"
}

variable "system_name" {
  default = "efi"
}

variable "environment_tag" {
  default = "eFiling QA Suriname"
}

variable "product_tag" {
  default = "efi"
}

variable "role_tag" {
  default = "qa"
}


# You'll usually want to set this to a region near you.
variable "location" {
  default = "eastus2"
}

#####################################################################################################
#refer to an existing vnet
data "azurerm_virtual_network" "existing_virtualnet" {
  name                 = "RG_EastUS2_Demo-vnet2"
  resource_group_name  = "RG_EastUS2_Demo"
}
#refer to an existing subnet
data "azurerm_subnet" "existing_subnet" {
  name                 = "Subnetwork2"
  virtual_network_name = "RG_EastUS2_Demo-vnet2"
  resource_group_name  = "RG_EastUS2_Demo"
}
# Imported resource group
data "azurerm_resource_group" "existing_resource_group" {
  name     = "RG_EastUS2_Demo"
}

#####################################################################################################
# This is for the load balancer box
resource "azurerm_network_interface" "new_terraform_lb01_nic01" {
    name                      = "${var.environment_prefix}-${var.system_name}-lb01_nic01"
    resource_group_name       = data.azurerm_resource_group.existing_resource_group.name
    location                  = data.azurerm_resource_group.existing_resource_group.location

    ip_configuration {
        name                           = "lb01-nic01_conf"
        subnet_id                      = data.azurerm_subnet.existing_subnet.id
        private_ip_address_allocation  = "Dynamic"
    }

    tags = {
        environment = "${var.environment_tag}"
        product = "${var.product_tag}"
        role = "${var.role_tag}"
    }
}

#########################################################################################
#VM Creation
resource "azurerm_virtual_machine" "new_terraform_lb01" {
    name                  = "${var.environment_prefix}-${var.system_name}-lb01"
    location              = "eastus2"
    resource_group_name   = data.azurerm_resource_group.existing_resource_group.name
    network_interface_ids = ["${azurerm_network_interface.new_terraform_lb01_nic01.id}"]
    vm_size               = "Standard_B2ms"

    storage_os_disk {
        name              = "${var.environment_prefix}-${var.system_name}-lb01_osDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    delete_os_disk_on_termination = true
    
    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.environment_prefix}-${var.system_name}-lb01"
        admin_username = var.admin_username
	    admin_password = var.admin_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "${var.environment_tag}"
        product = "${var.product_tag}"
        role = "${var.role_tag}"
    }
}

