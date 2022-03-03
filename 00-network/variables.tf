variable "profile" {
  type = string
  description = "Profile défini dans le fichier credential d'aws"
}

variable "region" {
  type = string
  description = "Région aws où on déploie les ressources"
}

variable "my_ip" {
  type = string
  description = "Adresse ip de la machine à partir de laquelle on se connectera en ssh à l'instance ec2/"
}
