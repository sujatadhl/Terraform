terraform {  
    backend "s3" {    
    region         = "us-east-1"    
    key            = "<account_id>/<state_key>.tfstate"    
    bucket         = "8586-terraform-state"  
    }
}