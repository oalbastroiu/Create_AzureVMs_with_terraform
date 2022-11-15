node_location       = "West Europe"
resource_prefix     = "linuxVM"
node_address_space  = "10.0.0.0/16"
node_address_prefix = "10.0.0.0/24"
node_count          = 3
image = {
  image_publisher = "Canonical"
  image_type      = "UbuntuServer"
  image_sku       = "16.04-LTS"
}
vm_size          = "Standard_B1s"
public_key_path  = "~/.ssh/id_rsa.pub"
private_key_path = "~/.ssh/id_rsa"