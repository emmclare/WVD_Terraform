variable "deploylocation" {
  type        = string
  default     = "West Europe"
  description = "location"
}

variable "rgname"{
 type = string
 default = "WVD-TF"
 description = "resource group name"
}

variable "local_admin_username"{
 type = string
 default = "localadm"
 description = "admin username"
}

variable "admin_username"{
 type = string
 description = "admin username"
 
}

variable "admin_password"{
 type = string
 description = "admin password"
 
}


variable "rdsh_count" {
  description = "**OPTIONAL**: Number of WVD machines to deploy"
  default     = 2
}

variable "host_pool_name" {
  description = "Name of the RDS host pool"
  default     = ""
}

variable "vm_prefix" {
  description = "Prefix of the name of the WVD machine(s)"
}


variable "registration_expiration_hours" {
  description = "**OPTIONAL**: The expiration time for registration in hours"
  default     = "48"
}

variable "domain_name" {
  type = string
  description = "**OPTIONAL**: Name of the domain to join"
}

variable "domain_user_upn" {
  type = string
  description = "**OPTIONAL**: UPN of the user to authenticate with the domain"
 
}

variable "domain_password" {
  type = string
  description = "**OPTIONAL**: Password of the user to authenticate with the domain"
 
}

variable "base_url" {
  description = "**OPTIONAL**: The URL in which the RDS components exist"
  default     = "https://raw.githubusercontent.com/Azure/RDS-Templates/master/wvd-templates"
}

variable "vm_size" {
  description = "**OPTIONAL**: Size of the machine to deploy"
  default     = "Standard_F2s"
}

variable "ou_path" {
  default = ""

}

variable "adVnet"{
 type = string
 default = "adVNET"
 description = "resource group name"
}

variable "adRG"{
 type = string
 default = "RG-WVD-Internal"
 description = "resource group name"
}

variable "adVnetID"{
 type = string
  description = "resource group name"
}