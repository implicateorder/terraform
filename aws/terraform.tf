terraform {  
    backend "s3" {
        bucket  = "dl-terraform-state-db"
        encrypt = true
        key     = "terraform.tfstate"    
        region  = "us-east-2"  
    }
}
