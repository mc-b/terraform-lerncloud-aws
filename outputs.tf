
output "ip_vm" {
  description = "IP-Adressen der VMs"
  value = {
    for name, vm in aws_instance.vm :
    name => vm.public_ip
  }
}

output "fqdn_vm" {
  description = "DNS-Namen der VMs"
  value = {
    for name, vm in aws_instance.vm :
    name => vm.public_dns
  }
}

output "fqdn_private" {
  description = "Interne DNS-Namen der EC2-Instanzen"
  value = {
    for name, inst in aws_instance.vm :
    name => inst.private_dns
  }
}

output "description" {
  value       = var.description
  description = "Beschreibung VM (Default)"
}


