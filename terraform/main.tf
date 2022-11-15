# Create a resource group
resource "azurerm_resource_group" "assessment_rg" {
  name     = "${var.resource_prefix}-RG"
  location = var.node_location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "assessment_vnet" {
  name                = "${var.resource_prefix}-vnet"
  resource_group_name = azurerm_resource_group.assessment_rg.name
  location            = var.node_location
  address_space       = [var.node_address_space]
}

# Create a subnets within the virtual network
resource "azurerm_subnet" "assessment_subnet" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.assessment_rg.name
  virtual_network_name = azurerm_virtual_network.assessment_vnet.name
  address_prefixes     = [var.node_address_prefix]
}

# Create public IP
resource "azurerm_public_ip" "assessment_public_ip" {
  count               = var.node_count
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-PublicIP"
  location            = azurerm_resource_group.assessment_rg.location
  resource_group_name = azurerm_resource_group.assessment_rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "Dev"
  }
}

# Create Network Interface
resource "azurerm_network_interface" "assessment_nic" {
  count               = var.node_count
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-NIC"
  location            = azurerm_resource_group.assessment_rg.location
  resource_group_name = azurerm_resource_group.assessment_rg.name
  #

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.assessment_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.assessment_public_ip.*.id, count.index)
  }
}

# Creating resource NSG
resource "azurerm_network_security_group" "assessment_nsg" {

  name                = "${var.resource_prefix}-NSG"
  location            = azurerm_resource_group.assessment_rg.location
  resource_group_name = azurerm_resource_group.assessment_rg.name
  security_rule {
    name                       = "Inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.node_address_prefix
    destination_address_prefix = var.node_address_prefix

  }
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "dev"
  }
}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "assessment_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.assessment_subnet.id
  network_security_group_id = azurerm_network_security_group.assessment_nsg.id

}

# Generate random passwords

resource "random_password" "password" {
  count            = var.node_count
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Virtual Machine Creation — Linux
resource "azurerm_linux_virtual_machine" "assessment_vms" {
  count                           = var.node_count
  name                            = "${var.resource_prefix}-${format("%02d", count.index)}"
  location                        = azurerm_resource_group.assessment_rg.location
  resource_group_name             = azurerm_resource_group.assessment_rg.name
  network_interface_ids           = [element(azurerm_network_interface.assessment_nic.*.id, count.index)]
  size                            = var.vm_size
  disable_password_authentication = false
  admin_username                  = "vmadmin"
  admin_password                  = random_password.password[count.index].result

  admin_ssh_key {
    username   = "vmadmin"
    public_key = file("${var.public_key_path}")
  }
  source_image_reference {
    publisher = var.image["image_publisher"]
    offer     = var.image["image_type"]
    sku       = var.image["image_sku"]
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags = {
    environment = "dev"
  }
}

resource "null_resource" "run_script" {
  triggers = {
    public_ip_address = azurerm_linux_virtual_machine.assessment_vms[var.node_count - 1].public_ip_address
  }
  count = var.node_count
  #   connection {
  #     type = "ssh"
  #     user        = "vmadmin"
  #     private_key = "${file(var.private_key_path)}"
  #     host = element(azurerm_linux_virtual_machine.assessment_vms[*].public_ip_address, count.index)
  #   } 
  #     provisioner "file" {
  #     source      = "~/Create_AzureVMs_with_terraform/shell_scripts/testping.sh"
  #     destination = "/tmp/testping.sh"
  #   }
  # de inlocuita comanda cu script
  provisioner "local-exec" {
    command = "~/Create_AzureVMs_with_terraform/shell_scripts/testping.sh ${count.index} ${var.node_count} ${element(azurerm_linux_virtual_machine.assessment_vms[*].private_ip_address, 0)} ${element(azurerm_linux_virtual_machine.assessment_vms[*].private_ip_address, count.index)} ${element(azurerm_linux_virtual_machine.assessment_vms[*].private_ip_address, count.index + 1)} ${element(azurerm_linux_virtual_machine.assessment_vms[*].public_ip_address, count.index)}"
  }
}

data "local_file" "testfile" {
  depends_on = [null_resource.run_script]
  filename   = "${path.module}/ping_result.txt"
}

output "results" {
  value = [data.local_file.testfile.content]
}

output "ips" {
  value = [azurerm_linux_virtual_machine.assessment_vms[*].public_ip_address]
}

output "passwords" {
  value     = [azurerm_linux_virtual_machine.assessment_vms[*].admin_password]
  sensitive = true
}
