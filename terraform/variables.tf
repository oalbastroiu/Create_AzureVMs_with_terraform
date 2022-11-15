variable "node_location" {
  description = "Location of the VMs"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the name of the resources in the project"
  type        = string
}

variable "node_address_space" {
  description = "Range for virtual network"
  type        = string
}

#variable for network range

variable "node_address_prefix" {
  description = "Prefix address for the subnet"
  type        = string
}

variable "node_count" {
  description = "Number of VMs to create"
  type        = number
}

variable "image" {
  description = "Details about the image used: image_publisher,image_type,image_sku"
  type        = map(any)
}

variable "public_key_path" {
  description = "The path to the public key that you want to copy on the VMs"
  type        = string
}

variable "vm_size" {
  description = "VMs type/size"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key used to connect on the VMs."
  type        = string
}