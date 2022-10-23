resource "aws_instance" "jenkins" {
    ami = var.ami
    instance_type = var.itype
    associate_public_ip_address = var.publicip
    key_name = var.keyname
    user_data = <<EOF
                #!/bin/bash
                curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-4/main/Runners/runinstalljenkins.sh && sudo chmod +x runinstalljenkins.sh && sudo ./runinstalljenkins.sh
                EOF
    security_groups = [
        var.secgroupname
    ]
    
    tags = {
        Name = var.ec2name
    }
}