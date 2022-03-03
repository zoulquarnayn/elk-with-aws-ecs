# Création du VPC du cluster elk
resource "aws_vpc" "main"{
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "elk-cluster-vpc"
    }
}

# Création du subnet dans lequel le cluster elk sera installé. Il s'agit d'un public subnet afin qu'on puisse accéder au cluster depuis internet.
resource "aws_subnet" "public_elk" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-public-elk"
  }
}

# Création d'un deuxième subnet public où on installera une instance ec2 permettant d'envoyer des métriques au cluster elk.
resource "aws_subnet" "public_other" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public-other"
  }
}

# Création de l'internet gateway qui sera rattaché aux 2 subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "elk-cluster-igw"
  }
}

# create route tableCréation de la table de routage du vpc
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "elk-cluster-route-table"
  }
}

# Association de la table de routage au subnet elk
resource "aws_route_table_association" "public_elk_rt_association" {
  subnet_id = aws_subnet.public_elk.id
  route_table_id = aws_route_table.main.id
}

# Association de la table de routage au subnet other
resource "aws_route_table_association" "public_other_rt_association" {
  subnet_id = aws_subnet.public_other.id
  route_table_id = aws_route_table.main.id
}

# Création du security group protégeant l'accès au cluster elk
resource "aws_security_group" "allow_access_elk"{
    name = "allow_access_elk"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "allow access to elasticsearch"
        from_port   = 9200
        to_port     = 9200
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.main.cidr_block]
    }

    ingress {
        description = "allow access to kibana"
        from_port   = 5601
        to_port     = 5601
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "allow access to logstash"
        from_port   = 5044
        to_port     = 5044
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.main.cidr_block]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}

# Création du subnet group protégeant l'accès à l'instance ec2.
resource "aws_security_group" "allow_ssh"{
    name = "allow_ssh"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "allow access to ec2 instance via ssh"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.my_ip]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

}
