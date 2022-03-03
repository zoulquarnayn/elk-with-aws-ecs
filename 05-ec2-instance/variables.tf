variable "profile" {
  type = string
  description = "profile defined in aws credential file"
}

variable "region" {
  type = string
  description = "AWS region where we deploy resources"
}

variable "key_name" {
  type = string
  description = "ssh public key name to use to connect to ec2 instance. This is publihed also on aws envrionment."
}

variable "ssh_private_key_path" {
  type = string
  description = "The path of private ssh key to use to connect to ec2 instance"
}