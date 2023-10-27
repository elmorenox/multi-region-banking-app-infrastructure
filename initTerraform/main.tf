resource "aws_vpc" "us_east_region" {
  provider             = aws
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc-us-east-1"
  }
}

resource "aws_vpc" "us_west_region" {
  provider             = aws.us_west
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc-us-west-2"
  }
}

// create internet gateway
resource "aws_internet_gateway" "east_igw" {
  provider = aws
  vpc_id   = aws_vpc.us_east_region.id
}

resource "aws_internet_gateway" "west_igw" {
  provider = aws.us_west
  vpc_id   = aws_vpc.us_west_region.id
}

// create subnets
resource "aws_subnet" "east_public_subnet" {
  count             = 2
  provider          = aws
  cidr_block        = count.index == 0 ? var.public_subnet_cidr_blocks[0] : var.public_subnet_cidr_blocks[1]
  vpc_id            = aws_vpc.us_east_region.id
  availability_zone = count.index == 0 ? var.public_subnet_azs[0] : var.public_subnet_azs[1]
  tags = {
    Name = "east-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "west_public_subnet" {
  count             = 2
  provider          = aws.us_west
  cidr_block        = count.index == 0 ? var.public_subnet_cidr_blocks[0] : var.public_subnet_cidr_blocks[1]
  vpc_id            = aws_vpc.us_west_region.id
  availability_zone = count.index == 0 ? var.public_subnet_azs[2] : var.public_subnet_azs[3]
  tags = {
    Name = "west-public-subnet-${count.index}"
  }
}

// create EC2 instances
resource "aws_instance" "east_ec2" {
  key_name                    = var.key_names[0]
  count                       = 2
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  subnet_id                   = count.index == 0 ? aws_subnet.east_public_subnet[0].id : aws_subnet.east_public_subnet[1].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.east_sg.id]
  user_data                   = file("install-banking-app.sh")
  tags = {
    Name = count.index == 0 ? var.ec2_names[0] : var.ec2_names[1]
  }
}

resource "aws_instance" "west_ec2" {
  provider                    = aws.us_west
  key_name                    = var.key_names[1]
  count                       = 2
  ami                         = "ami-0efcece6bed30fd98"
  instance_type               = "t2.micro"
  subnet_id                   = count.index == 0 ? aws_subnet.west_public_subnet[0].id : aws_subnet.west_public_subnet[1].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.west_sg.id]
  user_data                   = file("install-banking-app.sh")
  tags = {
    Name = count.index == 0 ? var.ec2_names[2] : var.ec2_names[3]
  }
}

// create security group
resource "aws_security_group" "east_sg" {
  provider = aws
  name     = "east-http-ssh-sg"
  vpc_id   = aws_vpc.us_east_region.id
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_vpc.us_east_region
  ]
}


resource "aws_security_group" "west_sg" {
  provider = aws.us_west
  name     = "west-http-ssh-sg"
  vpc_id   = aws_vpc.us_west_region.id
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_vpc.us_west_region
  ]
}
// create route table
resource "aws_route_table" "east_route_table" {
  provider = aws
  vpc_id   = aws_vpc.us_east_region.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.east_igw.id
  }
  tags = {
    Name = "route-table-${var.vpc_names[0]}"
  }
}

resource "aws_route_table" "west_route_table" {
  provider = aws.us_west
  vpc_id   = aws_vpc.us_west_region.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.west_igw.id
  }
  tags = {
    Name = "route-table-${var.vpc_names[1]}"
  }
}

// associate route table with subnets
resource "aws_route_table_association" "east_route_table_association" {
  provider       = aws
  count          = 2
  subnet_id      = count.index == 0 ? aws_subnet.east_public_subnet[0].id : aws_subnet.east_public_subnet[1].id
  route_table_id = aws_route_table.east_route_table.id
}
resource "aws_route_table_association" "west_route_table_association" {
  provider       = aws.us_west
  count          = 2
  subnet_id      = count.index == 0 ? aws_subnet.west_public_subnet[0].id : aws_subnet.west_public_subnet[1].id
  route_table_id = aws_route_table.west_route_table.id
}
