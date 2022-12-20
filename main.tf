# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
  backend "azurerm" {
    resource_group_name   = "vzapps-tf"
    storage_account_name  = "terraformac"
    container_name        = "terraform"
    key                   = "terraform.tfstate"
    }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }

    skip_provider_registration = true

}
data "azurerm_client_config" "current" {}


#################################################################
#                                                               #
#                   West Europe Verizon App                     #
#                                                               #
##################################################################

# Create the resource groups pour vzapps
resource "azurerm_resource_group" "we-vzapps" {
  name     = "rg-tea-we-vzapps"
  location = "West Europe"
}
#
#
# Change keyvault name for Prod
#
#
#
## Keyvault creation code
resource "azurerm_key_vault" "keyvault" {
  name                = "prod-kv-we-test"
  location            = azurerm_resource_group.we-vzapps.location
  resource_group_name = azurerm_resource_group.we-vzapps.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}
resource "azurerm_key_vault_access_policy" "keyvault-AccessPolicy" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore","Create","Update","Import",
  ]

  secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore","Set",
  ]
  storage_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore",
  ]
  certificate_permissions = [
    "Get","List","Create","Update","Import","Delete","Recover","Backup","Restore","Purge",
  ]
}

#Create KeyVault admin-password for Grid Master VM
resource "random_password" "GM-adminuser" {
  length = 20
  special = true
}
#Create Key Vault Secret for Grid Master admin-password 
resource "azurerm_key_vault_secret" "GM-adminuser" {
  name         = "gmadmin"
  value        = random_password.GM-adminuser.result
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on = [ azurerm_key_vault_access_policy.keyvault-AccessPolicy]
}

#Create KeyVault admin-password for reporting VM
resource "random_password" "RP-adminuser" {
  length = 20
  special = true
}
#Create Key Vault Secret for Grid Master admin-password 
resource "azurerm_key_vault_secret" "RP-adminuser" {
  name         = "rpadmin"
  value        = random_password.RP-adminuser.result
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on = [ azurerm_key_vault_access_policy.keyvault-AccessPolicy]
}

#Create KeyVault admin-password for Grid Master VM
resource "random_password" "CADNS-adminuser" {
  length = 20
  special = true
}
#Create Key Vault Secret for Grid Master admin-password 
resource "azurerm_key_vault_secret" "CADNS-adminuser" {
  name         = "cadnsadmin"
  value        = random_password.CADNS-adminuser.result
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on = [ azurerm_key_vault_access_policy.keyvault-AccessPolicy]
}

# Create NSG for DDIMGMT subnet
resource "azurerm_network_security_group" "weddimgmt" {
  name                = "nsg-tea-we-ddimgmt"
  location            = azurerm_resource_group.we-vzapps.location
  resource_group_name = azurerm_resource_group.we-vzapps.name

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"    
  }
  security_rule {
    name                       = "DNS-UDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"    
  }
  security_rule {
    name                       = "DNS-TCP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "GRID1"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "GRID2"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "2114"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create NSG for DDIPRD subnet
resource "azurerm_network_security_group" "weddiprd" {
  name                = "nsg-tea-we-ddiprd"
  location            = azurerm_resource_group.we-vzapps.location
  resource_group_name = azurerm_resource_group.we-vzapps.name

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"    
  }
  security_rule {
    name                       = "DNS-UDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"    
  }
  security_rule {
    name                       = "DNS-TCP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "GRID1"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "GRID2"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "2114"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Create NSG for NAC subnet
resource "azurerm_network_security_group" "weddinac" {
  name                = "nsg-tea-we-nac"
  location            = azurerm_resource_group.we-vzapps.location
  resource_group_name = azurerm_resource_group.we-vzapps.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "weapps" {
  name                = "vnet-tea-we-vzapps"
  resource_group_name = azurerm_resource_group.we-vzapps.name
  location            = azurerm_resource_group.we-vzapps.location
  address_space       = ["10.174.0.0/16"]
}

# Create ddimgmt subnet within the vnet
resource "azurerm_subnet" "weddimgmt" {
  name                 = "snet-tea-we-ddimgmt"
  resource_group_name  = azurerm_resource_group.we-vzapps.name
  virtual_network_name = azurerm_virtual_network.weapps.name
  address_prefixes     = ["10.174.32.0/28"]
  #network_security_group_id = azurerm_network_security_group.weddimgmt.id  
}
resource "azurerm_subnet_network_security_group_association" "weddimgmt-nsg" {
  subnet_id = azurerm_subnet.weddimgmt.id
  network_security_group_id = azurerm_network_security_group.weddimgmt.id
}

# Create ddiprd subnet within the vnet
resource "azurerm_subnet" "weddiprd" {
  name                 = "snet-tea-we-ddiprd"
  resource_group_name  = azurerm_resource_group.we-vzapps.name
  virtual_network_name = azurerm_virtual_network.weapps.name
  address_prefixes     = ["10.174.32.16/28"]  
}
resource "azurerm_subnet_network_security_group_association" "weddiprd-nsg" {
  subnet_id = azurerm_subnet.weddiprd.id
  network_security_group_id = azurerm_network_security_group.weddiprd.id
}


# Create storage account for boot diagnostics
#####
#####
####
####
#### remove test from the storage name in production deployment
####
####
####
####
resource "azurerm_storage_account" "bootdiastorageaccount-we" {
    name                        = "bootsateawedtest11"
    location                     = azurerm_resource_group.we-vzapps.location
    resource_group_name          = azurerm_resource_group.we-vzapps.name
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        
    }
}

/*
##########################################################
###### create Grid Master virtual machine ################
##########################################################
# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "ekprodweddigm-rg" {
    name     = "ekprodweddigm-rg"
    location = "West Europe"

    tags = {
        environment = "DDI-Prod"
    }
}
# create the mgmt network interface for GridMAster VM
resource "azurerm_network_interface" "ekprodweddigm-ddimgmt-nic" {
  name                = "ekprodweddigm-ddimgmt-nic"
  location            = azurerm_resource_group.we-vzapps.location
  resource_group_name = azurerm_resource_group.we-vzapps.name
  

  ip_configuration {
    name                          = "ekprodweddigm-mgmt-ipconfig1"
    subnet_id                     = azurerm_subnet.weddimgmt.id
    primary                       = true
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.174.32.4"
    
  }
}
# Create Prod network interface for GridMaster VM
resource "azurerm_network_interface" "ekprodweddigm-ddiprd-nic" {
  name                = "ekprodweddigm-ddiprd-nic"
  location            = azurerm_resource_group.we-vzapps.location
  resource_group_name = azurerm_resource_group.we-vzapps.name
  

  ip_configuration {
    name                          = "ekprodweddigm-prd-ipconfig1"
    subnet_id                     = azurerm_subnet.weddiprd.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.174.32.20"
    
  }
}

## create the virtual machine Grid Master
resource "azurerm_virtual_machine" "ekprodweddigm" {
  name                  = "EKPRODWEDDIGM"
  location              = azurerm_resource_group.ekprodweddigm-rg.location
  resource_group_name   = azurerm_resource_group.ekprodweddigm-rg.name
  network_interface_ids = [azurerm_network_interface.ekprodweddigm-ddimgmt-nic.id,azurerm_network_interface.ekprodweddigm-ddiprd-nic.id]
  primary_network_interface_id = azurerm_network_interface.ekprodweddigm-ddimgmt-nic.id
  vm_size                  = "Standard_DS12_v2"

  #delete_os_disk_on_termination = true
  #delete_data_disks_on_termination = true

  storage_image_reference {
        publisher = "infoblox"
        offer     = "infoblox-vm-appliances-862"
        sku       = "vsot"
        version   = "862.49947.0"
    }  
  storage_os_disk {
    name              = "osdisk-gm-we-vzapps"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    }
  # Specify the Azure marketplace item
  plan {
        name = "vsot"
        publisher = "infoblox"
        product = "infoblox-vm-appliances-862"
    }
  os_profile_linux_config {
    disable_password_authentication = false
    }

  os_profile {
    computer_name  = "ekprodweddigm"
    admin_username = "vzadmin"
    admin_password = azurerm_key_vault_secret.GM-adminuser.value
    }

  boot_diagnostics {
        enabled     = true
        storage_uri = azurerm_storage_account.bootdiastorageaccount-we.primary_blob_endpoint
    }
  
  tags = {
    environment = "DDI-Prod"
    }
}


########################################################
###### create Reporting virtual machine ################
##########################################################
# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "ekprodweddirpt-rg" {
    name     = "ekprodweddirpt-rg"
    location = "West Europe"

    tags = {
        
    }
}
# create the mgmt network interface for Reporting VM
resource "azurerm_network_interface" "ekprodweddirpt-ddimgmt-nic" {
  name                = "ekprodweddirpt-ddimgmt-nic"
  location            = azurerm_resource_group.we-vzapps.location
  resource_group_name = azurerm_resource_group.we-vzapps.name
  

  ip_configuration {
    name                          = "ekprodweddirpt-mgmt-ipconfig1"
    subnet_id                     = azurerm_subnet.weddimgmt.id
    primary                       = true
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.174.32.5"
    
  }
}
# Create Prod network interface for Reporting VM
resource "azurerm_network_interface" "ekprodweddirpt-ddiprd-nic" {
  name                = "ekprodweddirpt-ddiprd-nic"
  location            = azurerm_resource_group.we-vzapps.location
  resource_group_name = azurerm_resource_group.we-vzapps.name
  

  ip_configuration {
    name                          = "ekprodweddirpt-prd-ipconfig1"
    subnet_id                     = azurerm_subnet.weddiprd.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.174.32.21"
    
  }
}
## create the virtual machine Reporting
resource "azurerm_virtual_machine" "ekprodweddirpt" {
  name                  = "EKPRODWEDDIRPT"
  location              = azurerm_resource_group.ekprodweddirpt-rg.location
  resource_group_name   = azurerm_resource_group.ekprodweddirpt-rg.name
  network_interface_ids = [azurerm_network_interface.ekprodweddirpt-ddimgmt-nic.id,azurerm_network_interface.ekprodweddirpt-ddiprd-nic.id]
  primary_network_interface_id = azurerm_network_interface.ekprodweddirpt-ddimgmt-nic.id
  vm_size                  = "Standard_DS14_v2"

  #delete_os_disk_on_termination = true
  #delete_data_disks_on_termination = true

  storage_image_reference {
        publisher = "infoblox"
        offer     = "infoblox-vm-appliances-862"
        sku       = "ib-v5005"
        version   = "862.49947.0"
    }  
  storage_os_disk {
    name              = "osdisk-rpt-we-vzapps"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  storage_data_disk {
    name  = "datadisk-rpt-we-vzapps"
    caching = "ReadWrite"
    disk_size_gb = 512
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = "1"
  }
  # Specify the Azure marketplace item
    plan {
        name = "ib-v5005"
        publisher = "infoblox"
        product = "infoblox-vm-appliances-862"
    }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  boot_diagnostics {
        enabled     = true
        storage_uri = azurerm_storage_account.bootdiastorageaccount-we.primary_blob_endpoint
  }

  os_profile {
    computer_name  = "ekprodweddirpt"
    admin_username = "vzadmin"
    admin_password = azurerm_key_vault_secret.RP-adminuser.value
  }
  
  tags = {
    
  }
}
*/

##########################################################
###### create Cloud Automation virtual machine ################
##########################################################
# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "ekprodweddicadns-rg" {
    name     = "ekprodweddicadns-rg"
    location = "West Europe"

    tags = {
        
    }
}
# create the mgmt network interface for Cloud Automation VM
resource "azurerm_network_interface" "ekprodweddicadns-ddimgmt-nic" {
  name                = "ekprodweddicadns-ddimgmt-nic"
  location            = azurerm_resource_group.we-vzapps.location
  resource_group_name = azurerm_resource_group.we-vzapps.name
  

  ip_configuration {
    name                          = "ekprodweddicadns-mgmt-ipconfig1"
    subnet_id                     = azurerm_subnet.weddimgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.174.32.6"
    
  }
}
# Create Prod network interface for Cloud Automation VM
resource "azurerm_network_interface" "ekprodweddicadns-ddiprd-nic" {
  name                = "ekprodweddicadns-ddiprd-nic"
  location            = azurerm_resource_group.we-vzapps.location
  resource_group_name = azurerm_resource_group.we-vzapps.name
  

  ip_configuration {
    name                          = "ekprodweddicadns-prd-ipconfig1"
    subnet_id                     = azurerm_subnet.weddiprd.id
    primary                       = true
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.174.32.22"
    
  }
}
## create the virtual machine Cloud Autonation
########################################################
resource "azurerm_virtual_machine" "ekprodweddicadns" {
  name                  = "EKPRODWEDDICADNS"
  location              = azurerm_resource_group.ekprodweddicadns-rg.location
  resource_group_name   = azurerm_resource_group.ekprodweddicadns-rg.name
  network_interface_ids = [azurerm_network_interface.ekprodweddicadns-ddimgmt-nic.id,azurerm_network_interface.ekprodweddicadns-ddiprd-nic.id]
  primary_network_interface_id = azurerm_network_interface.ekprodweddicadns-ddiprd-nic.id
  vm_size                  = "Standard_DS11_v2"

  #delete_os_disk_on_termination = true
  #delete_data_disks_on_termination = true

  storage_image_reference {
        publisher = "infoblox"
        offer     = "infoblox-vm-appliances-862"
        sku       = "cp-v805"
        version   = "862.49947.0"
  }  
  storage_os_disk {
    name              = "osdisk-cadns-we-vzapps"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  # Specify the Azure marketplace item
    plan {
        name = "cp-v805"
        publisher = "infoblox"
        product = "infoblox-vm-appliances-862"
    }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  os_profile {
    computer_name  = "ekprodweddicadns"
    admin_username = "vzadmin"
    admin_password = azurerm_key_vault_secret.CADNS-adminuser.value
  }

  boot_diagnostics {
        enabled     = true
        storage_uri = azurerm_storage_account.bootdiastorageaccount-we.primary_blob_endpoint
    }
  
  tags = {
    
  }
}





#################################################################
#                                                               #
#                North Europe Verizon App                     #
#                                                               #
#################################################################

# Create the resource groups pour vzapps2
resource "azurerm_resource_group" "ne-vzapps" {
  name     = "rg-tea-sc-vzapps"
  location = "North Europe"
}

## Keyvault creation code
resource "azurerm_key_vault" "keyvault2" {
  name                = "prod-kv-scvzapps-test"
  location            = azurerm_resource_group.ne-vzapps.location
  resource_group_name = azurerm_resource_group.ne-vzapps.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}
resource "azurerm_key_vault_access_policy" "keyvault-AccessPolicy2" {
  key_vault_id = azurerm_key_vault.keyvault2.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore","Create","Update","Import",
  ]

  secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore","Set",
  ]
  storage_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore",
  ]
  certificate_permissions = [
    "Get","List","Create","Update","Import","Delete","Recover","Backup","Restore","Purge",
  ]
}

#Create KeyVault admin-password for Grid Master VM candidate
resource "random_password" "GMC-adminuser" {
  length = 20
  special = true
}
#Create Key Vault Secret for Grid Master Candidate admin-password 
resource "azurerm_key_vault_secret" "GMC-adminuser" {
  name         = "gmcadmin"
  value        = random_password.GMC-adminuser.result
  key_vault_id = azurerm_key_vault.keyvault2.id
  depends_on = [ azurerm_key_vault_access_policy.keyvault-AccessPolicy2]
}

#Create KeyVault admin-password for Cloud Automation VM
resource "random_password" "CADNS2-adminuser" {
  length = 20
  special = true
}
#Create Key Vault Secret for Cloud Automation admin-password 
resource "azurerm_key_vault_secret" "CADNS2-adminuser" {
  name         = "cadnsadmin2"
  value        = random_password.CADNS2-adminuser.result
  key_vault_id = azurerm_key_vault.keyvault2.id
  depends_on = [ azurerm_key_vault_access_policy.keyvault-AccessPolicy2]
}

#Create KeyVault admin-password for Backup VM
resource "random_password" "BKP-adminuser" {
  length = 20
  special = true
}
#Create Key Vault Secret for Backup admin-password 
resource "azurerm_key_vault_secret" "BKP-adminuser" {
  name         = "bkpadmin"
  value        = random_password.BKP-adminuser.result
  key_vault_id = azurerm_key_vault.keyvault2.id
  depends_on = [ azurerm_key_vault_access_policy.keyvault-AccessPolicy2]
}

# Create NSG for DDIMGMT subnet
resource "azurerm_network_security_group" "scddimgmt" {
  name                = "nsg-tea-sc-ddimgmt"
  location            = azurerm_resource_group.ne-vzapps.location
  resource_group_name = azurerm_resource_group.ne-vzapps.name

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"    
  }
  security_rule {
    name                       = "DNS-UDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"    
  }
  security_rule {
    name                       = "DNS-TCP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "GRID1"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "GRID2"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "2114"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


}

# Create NSG for DDIPRD subnet
resource "azurerm_network_security_group" "scddiprd" {
  name                = "nsg-tea-sc-ddiprd"
  location            = azurerm_resource_group.ne-vzapps.location
  resource_group_name = azurerm_resource_group.ne-vzapps.name

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"    
  }
  security_rule {
    name                       = "DNS-UDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"    
  }
  security_rule {
    name                       = "DNS-TCP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "GRID1"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "GRID2"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "2114"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


}

# Create NSG for NAC subnet
resource "azurerm_network_security_group" "scddinac" {
  name                = "nsg-tea-sc-nac"
  location            = azurerm_resource_group.ne-vzapps.location
  resource_group_name = azurerm_resource_group.ne-vzapps.name

  security_rule {
    name                       = "ssh"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "scapps" {
  name                = "vnet-tea-sc-vzapps"
  resource_group_name = azurerm_resource_group.ne-vzapps.name
  location            = azurerm_resource_group.ne-vzapps.location
  address_space       = ["10.175.0.0/16"]
}

# Create ddimgmt subnet within the vnet
resource "azurerm_subnet" "scddimgmt" {
  name                 = "snet-tea-sc-ddimgmt"
  resource_group_name  = azurerm_resource_group.ne-vzapps.name
  virtual_network_name = azurerm_virtual_network.scapps.name
  address_prefixes     = ["10.175.32.0/28"]  
}
resource "azurerm_subnet_network_security_group_association" "scddimgmt-nsg" {
  subnet_id = azurerm_subnet.scddimgmt.id
  network_security_group_id = azurerm_network_security_group.scddimgmt.id
}

# Create ddiprd subnet within the vnet
resource "azurerm_subnet" "scddiprd" {
  name                 = "snet-tea-sc-ddiprd"
  resource_group_name  = azurerm_resource_group.ne-vzapps.name
  virtual_network_name = azurerm_virtual_network.scapps.name
  address_prefixes     = ["10.175.32.16/28"]  
}
resource "azurerm_subnet_network_security_group_association" "scddiprd-nsg" {
  subnet_id = azurerm_subnet.scddiprd.id
  network_security_group_id = azurerm_network_security_group.scddiprd.id
}

# Create storage account for boot diagnostics
#####
#####
####
####
#### remove test from the storage name in production deployment
####
####
####
####
resource "azurerm_storage_account" "bootdiastorageaccount-sc" {
    name                        = "bootsatappstest"
    location                     = azurerm_resource_group.ne-vzapps.location
    resource_group_name          = azurerm_resource_group.ne-vzapps.name
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        
    }
}

/*
##########################################################
###### create Grid Master virtual machine candifate ################
##########################################################
# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "ekprodscddigmc-rg" {
    name     = "ekprodscddigmc-rg"
    location = "North Europe"

    tags = {
        
    }
}
# create the mgmt network interface for GridMAster VM
resource "azurerm_network_interface" "ekprodscddigmc-ddimgmt-nic" {
  name                = "ekprodscddigmc-ddimgmt-nic"
  location            = azurerm_resource_group.ne-vzapps.location
  resource_group_name = azurerm_resource_group.ne-vzapps.name
  

  ip_configuration {
    name                          = "ekprodscddigmc-mgmt-ipconfig1"
    subnet_id                     = azurerm_subnet.scddimgmt.id
    primary                       = true
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.175.32.4"
    
  }
}
# Create Prod network interface for GridMaster candidate VM
resource "azurerm_network_interface" "ekprodscddigmc-ddiprd-nic" {
  name                = "ekprodscddigmc-ddiprd-nic"
  location            = azurerm_resource_group.ne-vzapps.location
  resource_group_name = azurerm_resource_group.ne-vzapps.name
  

  ip_configuration {
    name                          = "ekprodscddigmc-prd-ipconfig1"
    subnet_id                     = azurerm_subnet.scddiprd.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.175.32.20"
    
  }
}

## create the virtual machine Grid Master candidate 
resource "azurerm_virtual_machine" "ekprodscddigmc" {
  name                  = "EKPRODSCDDIGMC"
  location              = azurerm_resource_group.ekprodscddigmc-rg.location
  resource_group_name   = azurerm_resource_group.ekprodscddigmc-rg.name
  network_interface_ids = [azurerm_network_interface.ekprodscddigmc-ddimgmt-nic.id,azurerm_network_interface.ekprodscddigmc-ddiprd-nic.id]
  primary_network_interface_id = azurerm_network_interface.ekprodscddigmc-ddimgmt-nic.id
  vm_size                  = "Standard_DS12_v2"

  #delete_os_disk_on_termination = true
  #delete_data_disks_on_termination = true

  storage_image_reference {
        publisher = "infoblox"
        offer     = "infoblox-vm-appliances-862"
        sku       = "vsot"
        version   = "862.49947.0"
    }  
  storage_os_disk {
    name              = "osdisk-gmc-sc-vzapps"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    }
  # Specify the Azure marketplace item
  plan {
        name = "vsot"
        publisher = "infoblox"
        product = "infoblox-vm-appliances-862"
    }
  os_profile_linux_config {
    disable_password_authentication = false
    }

  os_profile {
    computer_name  = "ekprodscddigmc"
    admin_username = "vzadmin"
    admin_password = azurerm_key_vault_secret.GMC-adminuser.value
    }

  boot_diagnostics {
        enabled     = true
        storage_uri = azurerm_storage_account.bootdiastorageaccount-sc.primary_blob_endpoint
    }
  
  tags = {
    
    }
}




##########################################################
###### create Cloud Automation Replica virtual machine ################
##########################################################
# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "ekprodscddicadns-rg" {
    name     = "ekprodscddicadns-rg"
    location = "North Europe"

    tags = {
        
    }
}
# create the mgmt network interface for Cloud Automation Replica VM
resource "azurerm_network_interface" "ekprodscddicadns-ddimgmt-nic" {
  name                = "ekprodscddicadns-ddimgmt-nic"
  location            = azurerm_resource_group.ne-vzapps.location
  resource_group_name = azurerm_resource_group.ne-vzapps.name
  

  ip_configuration {
    name                          = "ekprodscddicadns-mgmt-ipconfig1"
    subnet_id                     = azurerm_subnet.scddimgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.175.32.5"
    
  }
}
# Create Prod network interface for Cloud Automation VM
resource "azurerm_network_interface" "ekprodscddicadns-ddiprd-nic" {
  name                = "ekprodscddicadns-ddiprd-nic"
  location            = azurerm_resource_group.ne-vzapps.location
  resource_group_name = azurerm_resource_group.ne-vzapps.name
  

  ip_configuration {
    name                          = "ekprodscddicadns-prd-ipconfig1"
    subnet_id                     = azurerm_subnet.scddiprd.id
    primary                       = true
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.175.32.21"
    
  }
}
## create the virtual machine Cloud Autonation Replica
########################################################
resource "azurerm_virtual_machine" "ekprodscddicadns" {
  name                  = "EKPRODSCDDICADNS"
  location              = azurerm_resource_group.ekprodscddicadns-rg.location
  resource_group_name   = azurerm_resource_group.ekprodscddicadns-rg.name
  network_interface_ids = [azurerm_network_interface.ekprodscddicadns-ddimgmt-nic.id,azurerm_network_interface.ekprodscddicadns-ddiprd-nic.id]
  primary_network_interface_id = azurerm_network_interface.ekprodscddicadns-ddiprd-nic.id
  vm_size                  = "Standard_DS11_v2"

  #delete_os_disk_on_termination = true
  #delete_data_disks_on_termination = true

  storage_image_reference {
        publisher = "infoblox"
        offer     = "infoblox-vm-appliances-862"
        sku       = "cp-v805"
        version   = "862.49947.0"
  }  
  storage_os_disk {
    name              = "osdisk-cadns-sc-vzapps"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  # Specify the Azure marketplace item
    plan {
        name = "cp-v805"
        publisher = "infoblox"
        product = "infoblox-vm-appliances-862"
    }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  os_profile {
    computer_name  = "ekprodscddicadns"
    admin_username = "vzadmin"
    admin_password = azurerm_key_vault_secret.CADNS2-adminuser.value
  }

  boot_diagnostics {
        enabled     = true
        storage_uri = azurerm_storage_account.bootdiastorageaccount-sc.primary_blob_endpoint
    }
  
  tags = {
    
  }
}

*/

###### create Backup virtual machine ################
##########################################################
# create the mgmt network interface for Backup VM
resource "azurerm_network_interface" "ekprodscddibkp-ddimgmt-nic" {
  name                = "ekprodscddibkp-ddimgmt-nic"
  location            = azurerm_resource_group.ne-vzapps.location
  resource_group_name = azurerm_resource_group.ne-vzapps.name
  

  ip_configuration {
    name                          = "ekprodscddibkp-mgmt-ipconfig1"
    subnet_id                     = azurerm_subnet.scddimgmt.id
    primary                       = true
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.175.32.6"
    
  }
}
resource "azurerm_network_interface" "ekprodscddibkp-ddiprd-nic" {
  name                = "ekprodscddibkp-ddiprd-nic"
  location            = azurerm_resource_group.ne-vzapps.location
  resource_group_name = azurerm_resource_group.ne-vzapps.name
  

  ip_configuration {
    name                          = "ekprodscddibkp-prd-ipconfig1"
    subnet_id                     = azurerm_subnet.scddiprd.id
    primary                       = true
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.175.32.22"
    
  }
}
## create the virtual machine Cloud Automation
resource "azurerm_virtual_machine" "ekprodscddibkp" {
  name                  = "EKPRODSCDDIBKP"
  location              = azurerm_resource_group.ne-vzapps.location
  resource_group_name   = azurerm_resource_group.ne-vzapps.name
  network_interface_ids = [azurerm_network_interface.ekprodscddibkp-ddimgmt-nic.id,azurerm_network_interface.ekprodscddibkp-ddiprd-nic.id]
  primary_network_interface_id = azurerm_network_interface.ekprodscddibkp-ddimgmt-nic.id
  vm_size               = "Standard_B1ms"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "82gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "osdisk-bkp"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  storage_data_disk {
    name  = "datadisk-bkp"
    caching = "ReadWrite"
    disk_size_gb = 512
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = "1"
  }
  os_profile {
    computer_name  = "ekprodscddibkp"
    admin_username = "vzadmin"
    admin_password = azurerm_key_vault_secret.BKP-adminuser.value
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    
  }
}
