variable "region"{
    type = string
    default = "ap-northeast-1"
}

variable "ami"{
    type = string
    default = "ami-03f4fa076d2981b45"
}

variable "itype"{
    type = string
    default = "t2.micro"
}

variable "publicip"{
    type = bool
    default = true
}

variable "keyname"{
    type = string
    default = "Tokyo"
}

variable "secgroupname"{
    type = string
    default = "Jenkins Ports"
}

variable "bucketname"{
    type = string
    default = "Remote-Statefile"
}

variable "bucketacl"{
    type = string
    default = "private"
}

variable "ec2name"{
    type = string
    default = "Jenkins"
}