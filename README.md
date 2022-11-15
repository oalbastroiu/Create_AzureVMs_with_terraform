# Create_AzureVMs_with_terraform
You can find here the terraform code to create a configurable number of VMs in Azure with generated passwords. 
VMs pings each other to test the connectivity in a round robin fashion.


# Providers
Provider used to create the VMs is azurerm.
You need to configure the access for Terraform to the Azure subscription:
  subscription_id = "XXXXX-XXXXX-XXXXXXXX-XXXXXXXX"
  
  client_id       = "XXXXX-XXXXX-XXXXXXXX-XXXXXXXX"
  
  client_secret   = "XXXXX-XXXXX-XXXXXXXX-XXXXXXXX"
  
  tenant_id       = "XXXXX-XXXXX-XXXXXXXX-XXXXXXXX"
  

## Backend

The backend is configured to an Azure storage account so you need to provide the access variables in order to work:
resource_group_name
storage_account_name
container_name
key

## Usage

To provision this example, populate `terraform.tfvars` with the [required variables](#inputs) and run the following commands within
this directory:

- `terraform init` to initialize the directory
- `terraform plan` to generate the execution plan
- `terraform apply` to apply the execution plan
- `terraform destroy` to destroy the infrastructure

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| node\_location | Location of the VMs. | `string` | n/a | yes |
| resource\_prefix | Prefix for the name of the resources in the project. | `string` | n/a | yes |
| node\_address\_space | Range for virtual network. | `string` | `"default"` | no |
| node\_address\_prefix | Prefix address for the subnet. | `string` | n/a | yes |
| node\_count | Number of VMs to create. | `string` | n/a | yes |
| image | Details about the image used: image_publisher,image_type,image_sku. | `map` | n/a | yes |
| public\_key\_path | The path to the public key that you want to copy on the VMs. | `string` | n/a | yes |
| private\_key\_path | The path to the private key used to connect on the VMs. | `string` | n/a | yes |
| vm\_size | VMs type/size. | `string` | n/a | yes |


## How it works

The code creates a Resource group, virtual network within the resource group, subnets within the virtual network, public IPs in order to be able to access the VMs via ssh, NICs for every machine, a NSG where it configures ICMP access between the VMs and ssh access from internet. 
In the end it creates the Linux VMs. For password generation it's using random_password module. It also attaches a public ssh key to the VMs.

In order to test the ping between VMs the bash script shell_scripts/testping.sh is used. It is called by a local-exec provider.
The output is stored in a file on local filesystem which is used to create the output variable results.

