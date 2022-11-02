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
    default = "c5.xlarge"
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

variable "ec2name"{
    type = string
    default = "Jenkins"
}