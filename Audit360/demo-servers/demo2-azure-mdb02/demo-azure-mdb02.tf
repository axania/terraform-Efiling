# Configure the Azure Provider
provider "azurerm" { }

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
resource "azurerm_network_interface" "new_terraform_mdb02_nic01" {
    name                      = "demo-aud-mdb02_nic01"
    resource_group_name       = data.azurerm_resource_group.existing_resource_group.name
    location                  = data.azurerm_resource_group.existing_resource_group.location

    ip_configuration {
        name                           = "mdb02-nic01_conf"
        subnet_id                      = data.azurerm_subnet.existing_subnet.id
        private_ip_address_allocation  = "Dynamic"
    }

    tags = {
        environment = "Audit360 Demo Stack"
        product = "Audit360"
        role = "demo"
    }
}

#########################################################################################
#VM Creation
resource "azurerm_virtual_machine" "new_terraform_mdb02" {
    name                  = "demo-aud-mdb02"
    location              = "eastus2"
    resource_group_name   = data.azurerm_resource_group.existing_resource_group.name
    network_interface_ids = ["${azurerm_network_interface.new_terraform_mdb02_nic01.id}"]
    vm_size               = "Standard_B2ms"

    storage_os_disk {
        name              = "demo-aud-mdb02_osDisk"
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
        computer_name  = "demo-aud-mdb02"
        admin_username = "aud"
	    admin_password = "210z6vORtQz"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "Audit360 Demo Stack"
        product = "Audit360"
        role = "demo"
    }
}

