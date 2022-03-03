# ec2 instance qui hébergera filebeat. filebeat permet d'envoyer des métriques système à elk
resource "aws_instance" "filebeat_instance" {
  ami  = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  security_groups = [ data.aws_security_group.allow_ssh.id ]
  subnet_id = data.aws_subnet.public_other.id
  key_name = var.key_name 

  connection {
      type        = "ssh"
      host        = self.public_ip 
      user        = "ubuntu"
      private_key =  file(var.ssh_private_key_path)
  }
  
  provisioner "file" {
    source      = "filebeat.yml"
    destination = "/home/ubuntu/filebeat.yml"
  }
 
  provisioner "remote-exec" {
    inline = [
      "curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.17.0-amd64.deb",
      "yes | sudo dpkg -i filebeat-7.17.0-amd64.deb",
      "sudo cp filebeat.yml /etc/filebeat/filebeat.yml",
      "sudo filebeat modules enable system",
      "sudo service filebeat start"
    ]
  }

}

# get ubuntu ami id
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# datasource pour récupérer le security group créé par le fichier 00-netwotk\main.rf
data "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
}

# datasource pour récupérer le subnet public "other" créé par le fichier 00-netwotk\main.rf
data "aws_subnet" "public_other" {
  filter {
    name   = "tag:Name"
    values = ["subnet-public-other"]
  }
}