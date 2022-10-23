variable "region"{
    type = string
    default = "ap-northeast-1"
}

variable "bucketname"{
    type = string
    default = "terraform-remote-statefile-store"
}

variable "tablename"{
    type = string
    default = "terraform_state_lock_table"
}