variable "ssh_key_name" {
  description = "SSH name, it is required to be setted up previously on AWS, needed for sshing and getting the user data"
  type = string
}

variable "ssh_pem_path" {
  description = "SSH name, it is required to be setted up previously on AWS, needed for sshing and getting the user data, use unix sintax"
  type = string
}

variable "vpn_config_path" {
  description = "Path to the vpn config file please use finish it with .conf and use a unix sintax"
  type = string
}

variable "aws_region" {
  default = "sa-east-1"
  description = "Reagion to run the VPN on"
  type = string
}


variable "allowed_ip" {
  description = "Ips that are allowed to access the ec2 machine through tcp and udp, by default allows all"
  type = string
  default = "0.0.0.0/0"
}

variable "ubuntu_ami" {
  description = "AMI used for ubuntu, other OS will fail cause of the script.sh"
  type = string
  default = "ami-0fb4cf3a99aa89f72"
}



variable "bash_interpreter" {
  description = "Bash interpreter to be used, it defaults to windows git bash at C"
  default = "C:\\Program Files\\Git\\git-bash.exe"
  type = string
}

