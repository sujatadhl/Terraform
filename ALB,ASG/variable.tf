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


variable "instance_type"{
    type = string
    description = "Instance type"
  }

variable "ami_id" {
    type = string
    description = "AMI Id for ubuntu"
}

variable "ami_key_pair_name" {
    type= string  
    description = "key pair name"
    
}    

variable "engine"{
  type = string
  description = "database"
}

variable "storage_type"{
  type = string
  description = "storage_type"
}

variable "instance_class"{
  type = string
  description = "storage_type"
}

