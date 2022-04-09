###
#   Outputs wie IP-Adresse und DNS Name
#

output "ip_vm" {
  value = aws_instance.vm.public_ip
  description = "The IP address of the AWS server instance."
  
}

output "ip_fqdn" {
  value = aws_instance.vm.public_dns
  description = "The FQDN of the AWS server instance."
  
}