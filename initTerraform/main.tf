resource "aws_vpc" "us_east_region" {
    provider = aws
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "vpc-us-east-1"
    }
}

resource "aws_vpc" "us_west_region" {
    provider = aws.us_west
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "vpc-us-west-2"
    }
}


// create subnets
resource "aws_subnet" "public_subnet" {
  count = 4
  cidr_block = var.public_subnet_cidr_blocks[count.index % 2] // if index is even select the first in the cidr block list otherwise the other
  vpc_id = count.index < 3 ? aws_vpc.us_east_region.id : aws_vpc.us_west_region.id // first two subnets on one vpc the other 2 on the 2nd
  availability_zone = var.public_subnet_azs[count.index]
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

// create EC2 instances
resource "aws_instance" "ec2" {
    key_name = var.key_name
    count = 4
    ami = "ami-0c94855ba95c71c99"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet[count.index].id
    associate_public_ip_address = true
    vpc_security_group_ids = [
        count.index < 3 ? aws_security_group.sg[0].id : aws_security_group.sg[1].id // 1st two get 1 sg 2nd two get the other
    ]
    user_data = file("install-banking-app.sh")
    tags = {
        Name = var.ec2_names[count.index]
    }
}

// create security group
resource "aws_security_group" "sg" {
    count = 2
    name = "${var.vpc_names[count.index]}-http-ssh-sg"
    vpc_id = count.index == 1 ? aws_vpc.us_east_region.id : aws_vpc.us_west_region.id

    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// create route table
resource "aws_route_table" "route_table" {
    count = 2
    vpc_id = count.index == 1 ? aws_vpc.us_east_region.id : aws_vpc.us_west_region.id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw[count.index].id
    }
    tags = {
        Name = "route-table-${var.vpc_names[count.index]}"
    }
}

// associate route table with subnets
resource "aws_route_table_association" "route_table_association" {
    count = 4
    subnet_id = aws_subnet.public_subnet[count.index].id
    route_table_id = count.index < 3 ? aws_route_table.route_table[0].id : aws_route_table.route_table[1].id // subnets in 1 vpc get 1 rt the other 2 in the other vpc get another rt
}

// create internet gateway
resource "aws_internet_gateway" "igw" {
    count = 2
    vpc_id = count.index == 1 ? aws_vpc.us_east_region.id : aws_vpc.us_west_region.id
}


output "ec2_ips" {
    value = [for instance in aws_instance.ec2 : instance.public_ip]
}
