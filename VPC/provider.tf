provider "aws" {  
    region  = "us-east-1"
    default_tags  {
        tags = {
        silo = "intern"
        project = "vpc"
        owner = "sujata.dahal"
        terraform = "true"
        }
    }
    }