# Configure the Azure Provider
provider "azurerm" {
  version         = ">= 2.0"
  features {}
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
resource "azurerm_network_interface" "new_terraform_worker01_nic01" {
    name                      = "qa-ml-efi-worker01_nic01"
    resource_group_name       = data.azurerm_resource_group.existing_resource_group.name
    location                  = data.azurerm_resource_group.existing_resource_group.location

    ip_configuration {
        name                           = "worker01-nic01_conf"
        subnet_id                      = data.azurerm_subnet.existing_subnet.id
        private_ip_address_allocation  = "Dynamic"
    }

    tags = {
        environment = "eFiling QA Mali"
        product = "eFiling"
        role = "qa"
    }
}

#########################################################################################
#VM Creation
resource "azurerm_virtual_machine" "new_terraform_worker01" {
    name                  = "qa-ml-efi-worker01"
    location              = "eastus2"
    resource_group_name   = data.azurerm_resource_group.existing_resource_group.name
    network_interface_ids = ["${azurerm_network_interface.new_terraform_worker01_nic01.id}"]
    vm_size               = "Standard_B2ms"

    storage_os_disk {
        name              = "qa-ml-efi-worker01_osDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "qa-ml-efi-worker01"
        admin_username = "efi"
	    admin_password = "S4b4d0@w0rk#01"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "eFiling QA Mali"
        product = "eFiling"
        role = "qa"
    }
}

