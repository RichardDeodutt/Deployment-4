output "ec2publicip" {
  description = "The public ip of the jenkins ec2"
  value       = aws_instance.jenkins.public_ip
}