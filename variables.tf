
# Allgemeine Variablen

# Public Variablen

variable "module" {
    type    = string
    default = "base"
}

variable "userdata" {
    description = "Cloud-init Script"
    default = "/../../modules/base.yaml"
}

variable "ports" {
    type    = list(number)
    default = [ 22, 80 ]
}

variable "mem" {
    type    = string
    default = "1GB"
}

# Umwandlung "mem" nach AWS Instance Type

variable "instance_type" {
  type = map
  default = {
    "1GB" = "t2.micro"
    "2GB" = "t2.small"
    "4GB" = "t2.medium"
    "8GB" = "t2.large"
  }
}

# Scripts

data "template_file" "userdata" {
  template = file(var.userdata)
}
