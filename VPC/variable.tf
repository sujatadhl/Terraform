variable "cidr_value" {
  description = " CIDR Value defined"
  type = string
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
}

variable "public_subnets" {
    type        = list(string)
    description = "public subnets"    
    }

variable "private_subnets" {    
    type        = list(string)    
    description = "private subnets"    
    }