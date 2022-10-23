resource "aws_dynamodb_table" "terraform_state_lock_table" {
    name = "terraform_state_lock_table"
    hash_key = "LockID"
    read_capacity = 1
    write_capacity = 1
    
    attribute {
        name = "LockID"
        type = "S"
    }
}