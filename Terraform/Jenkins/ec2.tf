resource "aws_instance" "jenkins" {
    ami = var.ami
    instance_type = var.itype
    associate_public_ip_address = var.publicip
    key_name = var.keyname

    security_groups = [
        var.secgroupname
    ]
    
    tags = {
        Name = var.ec2name
    }
}

resource "null_resource" "execute" {
    provisioner "remote-exec" {
        connection {
            host = aws_instance.jenkins.public_dns
            user = "ubuntu"
            private_key = file("files/id_rsa")
        }
        
        inline = [
            "echo 'Waiting for cloud-init to finish' && cloud-init status --wait"
        ]
    }
}