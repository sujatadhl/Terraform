resource "aws_instance" "ec2_sujata" {  
    ami           = var.ami_id  
    instance_type = var.instance_type  
    subnet_id     = var.my_subnet  
    key_name      = var.ami_key_pair_name  
    associate_public_ip_address = "true"  
    tags = {    
        Name ="ec2_sujata"    
        silo = "intern"    
        project = "ec2"    
        terraform = true  
        }
    }