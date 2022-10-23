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