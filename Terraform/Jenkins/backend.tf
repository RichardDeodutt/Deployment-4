terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
    backend "s3" {
        encrypt = true
        bucket = "terraform_remote_statefile"
        dynamodb_table = "terraform_state_lock_table"
        key = "terraform.tfstate"
        region = "ap-northeast-1"
    }
}