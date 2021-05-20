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
  default     = "WVD-TF-HP"
}

variable "vm_prefix" {
  description = "Prefix of the name of the WVD machine(s)"
}



variable "domain_name" {
  type = string
  description = "Name of the domain to join"

}

variable "domain_user_upn" {
  type = string
  description = "UPN of the user to authenticate with the domain"
 
}

variable "domain_password" {
  type = string
  description = "Password of the user to authenticate with the domain"
 
}


variable "vm_size" {
  description = "Size of the machine to deploy"
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
 description = "resource group name for AD VM"
}

variable "adVnetID"{
 type = string
  description = "resource id for vnet"
}
