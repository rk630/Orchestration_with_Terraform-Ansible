terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.37.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" 
}
#vpc
resource "aws_vpc" "vpc_mern" {
  cidr_block = "10.0.0.0/16"
}

#public subnet

resource "aws_subnet" "public_mern" {
  vpc_id     = aws_vpc.vpc_mern.id
  cidr_block = "10.0.0.0/24"
  availability_zone  = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_mern"
  }
}
#private subnet
resource "aws_subnet" "private_mern" {
  vpc_id     = aws_vpc.vpc_mern.id
  cidr_block = "10.0.16.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "private_subnet_mern"
  }
}

#internet gateway

resource "aws_internet_gateway" "internet_gateway_mern" {
  vpc_id = aws_vpc.vpc_mern.id

  tags = {
    Name = "inetrnet_gateway_mern"
  }
}

#private nat

resource "aws_nat_gateway" "nat_mern" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private_mern.id
  
  tags = {
    Name = "private_nat_mern"
  }

}

#route table for public subnet

resource "aws_route_table" "public_subnet_route" {
  vpc_id = aws_vpc.vpc_mern.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_mern.id
  }
  tags = {
    Name = "public_route_table"
  }
}

#route table for nat(private subnet)

resource "aws_route_table" "private_subnet_route" {
  vpc_id = aws_vpc.vpc_mern.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_mern.id
  }
  tags = {
    Name = "private_route_table"
  }

}


#routing associations

resource "aws_route_table_association" "public_aws_route_table" {
  subnet_id      = aws_subnet.public_mern.id
  route_table_id = aws_route_table.public_subnet_route.id
}

resource "aws_route_table_association" "private_aws_internet_gateway" {
  subnet_id      = aws_subnet.private_mern.id
  route_table_id = aws_route_table.private_subnet_route.id
}

#security group
resource "aws_security_group" "mern_security_group" {
  name        = "mern_security_group"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc_mern.id

  tags = {
    Name = "mern_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_443" {
  security_group_id = aws_security_group.mern_security_group.id
#   cidr_ipv4         = aws_vpc.vpc_mern.cidr_block
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_22" {
  security_group_id = aws_security_group.mern_security_group.id
#   cidr_ipv4         = aws_vpc.vpc_mern.cidr_block
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_80" {
  security_group_id = aws_security_group.mern_security_group.id
#   cidr_ipv4         = aws_vpc.vpc_mern.cidr_block
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_3000" {
  security_group_id = aws_security_group.mern_security_group.id
#   cidr_ipv4         = aws_vpc.vpc_mern.cidr_block
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_3001" {
  security_group_id = aws_security_group.mern_security_group.id
#   cidr_ipv4         = aws_vpc.vpc_mern.cidr_block
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 3001
  ip_protocol       = "tcp"
  to_port           = 3001
}

#ec2

resource "aws_instance" "revanth_terraform" {
  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  subnet_id       = aws_subnet.public_mern.id
  key_name        = "revanth_personal"  # Change to your key pair
  vpc_security_group_ids  = [aws_security_group.mern_security_group.id]
#   vpc_security_group_ids = [aws_security_group.adarsh_terraform.id]  # Reference the existing security group

  tags = {
    Name = "revanth_mern_terraform"
  }
}

resource "aws_instance" "revanth_database" {
  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  subnet_id       = aws_subnet.private_mern.id
  key_name        = "revanth_personal"  # Change to your key pair
  vpc_security_group_ids  = [aws_security_group.mern_security_group.id]
#   vpc_security_group_ids = [aws_security_group.adarsh_terraform.id]  # Reference the existing security group

  tags = {
    Name = "revanth_database_terraform"
  }
}

output "public_ip_instance" {
    value = aws_instance.revanth_terraform.public_ip
}