# Configure the Azure Provider
# provider "azurerm" { }
provider "azurerm" {
  version         = ">= 2.0"
  features {}
}

variable "admin_password" {
# To be entered via command line when launching the terraform
# Please refer to the confluence page for the default password for this system-and-environment
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
# Network card creation for the 2 boxes
resource "azurerm_network_interface" "new_terraform_build01_nic01" {
    name                      = "dev-efi-build01_nic01"
    resource_group_name       = data.azurerm_resource_group.existing_resource_group.name
    location                  = data.azurerm_resource_group.existing_resource_group.location

    ip_configuration {
        name                           = "dev-efi-build01-nic01_conf"
        subnet_id                      = data.azurerm_subnet.existing_subnet.id
        private_ip_address_allocation  = "Dynamic"
    }

    tags = {
        environment = "dev"
        product = "efi"
        role = "jenkins builder"
    }
}

resource "azurerm_network_interface" "new_terraform_build02_nic01" {
    name                      = "dev-efi-build02_nic01"
    resource_group_name       = data.azurerm_resource_group.existing_resource_group.name
    location                  = data.azurerm_resource_group.existing_resource_group.location

    ip_configuration {
        name                           = "dev-efi-build02-nic01_conf"
        subnet_id                      = data.azurerm_subnet.existing_subnet.id
        private_ip_address_allocation  = "Dynamic"
    }

    tags = {
        environment = "dev"
        product = "efi"
        role = "jenkins builder"
    }
}

#########################################################################################
# VM Creation
# Box 1
resource "azurerm_virtual_machine" "new_terraform_build01" {
    name                  = "dev-efi-build01"
    location              = "eastus2"
    resource_group_name   = data.azurerm_resource_group.existing_resource_group.name
    network_interface_ids = ["${azurerm_network_interface.new_terraform_build01_nic01.id}"]
    vm_size               = "Standard_B2ms"

    storage_os_disk {
        name              = "dev-efi-build01_osDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
        disk_size_gb      = "150"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    # Uncomment this line to delete the data disks automatically when deleting the VM
    delete_data_disks_on_termination = "true"

    os_profile {
        computer_name  = "dev-efi-build01"
        admin_username = "efi"
  	    admin_password = var.admin_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "dev"
        product = "efi"
        role = "jenkins builder"
    }
}

# Box 2
resource "azurerm_virtual_machine" "new_terraform_build02" {
    name                  = "dev-efi-build02"
    location              = "eastus2"
    resource_group_name   = data.azurerm_resource_group.existing_resource_group.name
    network_interface_ids = ["${azurerm_network_interface.new_terraform_build02_nic01.id}"]
    vm_size               = "Standard_B2ms"

    storage_os_disk {
        name              = "dev-efi-build02_osDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
        disk_size_gb      = "150"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    # Uncomment this line to delete the data disks automatically when deleting the VM
    delete_data_disks_on_termination = "true"

    os_profile {
        computer_name  = "dev-efi-build02"
        admin_username = "efi"
  	    admin_password = var.admin_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "dev"
        product = "efi"
        role = "jenkins builder"
    }
}

