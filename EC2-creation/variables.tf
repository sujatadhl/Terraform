variable "instance_type"{    
    description = "Instance type"    
    default = "t2.micro"
    }

variable "ami_id" {    
    default= "ami-04b70fa74e45c3917"    
    description = "AMI Id for ubuntu"
    }

variable "my_subnet" {   
    default = "subnet-0f97b0bb45cdeb3b7"

}

variable "ami_key_pair_name" {        
    default = "sujata1"
    
    }