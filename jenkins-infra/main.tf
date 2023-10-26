provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "us-east-1"
  #profile = "Admin"
}


resource "aws_instance" "jenkins-host" {
  ami                     = "ami-053b0d53c279acc90"
  instance_type           = "t2.micro"
  subnet_id               = var.subnet_id
  key_name                = var.key_name

  vpc_security_group_ids = [var.vpc_security_group_ids]

  associate_public_ip_address = true

  user_data = file("jenkins-host-install.sh")

  tags = {
  }
}

resource "aws_instance" "jenkins-node" {
  ami                     = "ami-053b0d53c279acc90"
  instance_type           = "t2.micro"
  subnet_id               = var.subnet_id
  key_name                = var.key_name

  vpc_security_group_ids = [var.vpc_security_group_ids]

  associate_public_ip_address = true

  user_data = file("jenkins-node-install.sh")

  tags = {
    Name = "jenkins-node-east"
  }
}


output "instance_ip" {
    value = [aws_instance.jenkins-host.public_ip, aws_instance.jenkins-node.public_ip]

}