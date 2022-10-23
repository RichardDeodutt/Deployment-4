terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
    backend "s3" {
        encrypt = true
        bucket = "Remote-Statefile"
        dynamodb_table = "State-Table"
        key = "terraform.tfstate"
        region = "ap-northeast-1"
    }
}