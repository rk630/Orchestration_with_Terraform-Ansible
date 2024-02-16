# Orchestration_with_Terraform-Ansible

Part 1: Infrastructure Setup with Terraform

1. AWS Setup and Terraform Initialization:

   - Configure AWS CLI and authenticate with your AWS account.

   - Initialize a new Terraform project targeting AWS.
   - ![image](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/6c9018e4-753b-4271-b54e-e90997ae4399)


2. VPC and Network Configuration:

   - Create an AWS VPC with two subnets: one public and one private.
### Vpc
resource "aws_vpc" "vpc_mern" {
  cidr_block = "10.0.0.0/16"
}
![Screenshot 2024-02-16 192143](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/86b3b488-24ab-49d6-a287-a546b465b2ff)

### Public subnet
```
resource "aws_subnet" "public_mern" {
  vpc_id     = aws_vpc.vpc_mern.id
  cidr_block = "10.0.0.0/24"
  availability_zone  = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_mern"
  }
}
```
### Private subnet
```
resource "aws_subnet" "private_mern" {
  vpc_id     = aws_vpc.vpc_mern.id
  cidr_block = "10.0.16.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "private_subnet_mern"
  }
}
```
![Screenshot 2024-02-16 192157](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/c761f23e-3a15-4674-9bcc-e26d86c254be)

   - Set up an Internet Gateway and a NAT Gateway.

### Internet gateway

```
resource "aws_internet_gateway" "internet_gateway_mern" {
  vpc_id = aws_vpc.vpc_mern.id
  tags = {
    Name = "inetrnet_gateway_mern"
  }
}
```

![Screenshot 2024-02-16 193018](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/f1406a7f-f38d-44fd-9bcb-ff0a4b9f2735)
### Private nat
```
resource "aws_nat_gateway" "nat_mern" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private_mern.id
  tags = {
    Name = "private_nat_mern"
  }
}
```
![Screenshot 2024-02-16 192242](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/e08523e1-5589-402d-b16f-b1733bb58d7a)


   - Configure route tables for both subnets.

### Route table for public subnet
```
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
```
![image](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/f6712d6b-743f-49fb-961b-fd7a7c08bdd6)

### Route table for nat(private subnet)
```
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
```
![image](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/7dfe932f-0fc4-44a0-9d29-d6c362ae9636)

### Routing associations
```
resource "aws_route_table_association" "public_aws_route_table" {
  subnet_id      = aws_subnet.public_mern.id
  route_table_id = aws_route_table.public_subnet_route.id
}
resource "aws_route_table_association" "private_aws_internet_gateway" {
  subnet_id      = aws_subnet.private_mern.id
  route_table_id = aws_route_table.private_subnet_route.id
}
```

3. EC2 Instance Provisioning:

   - Launch two EC2 instances: one in the public subnet (for the web server) and another in the private subnet (for the database).


   - Ensure both instances are accessible via SSH (public instance only accessible from your IP).
   - ![Screenshot 2024-02-16 202349](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/4a3908c8-840e-415d-ade2-a43884e187a6)


4. Security Groups and IAM Roles:

   - Create necessary security groups for web and database servers.
  
### Security group
```
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
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_22" {
  security_group_id = aws_security_group.mern_security_group.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_80" {
  security_group_id = aws_security_group.mern_security_group.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_3000" {
  security_group_id = aws_security_group.mern_security_group.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_3001" {
  security_group_id = aws_security_group.mern_security_group.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 3001
  ip_protocol       = "tcp"
  to_port           = 3001
}
```
![Screenshot 2024-02-16 192111](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/a22a09f9-2446-4d7d-9344-97af48a9ad7d)

![Screenshot 2024-02-16 192339](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/4e5706d1-73f0-42e2-b004-b36a8fa09205)


   - Set up IAM roles for EC2 instances with required permissions.
   - ![Screenshot 2024-02-16 192025](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/6ab747b2-0ecb-414d-bfaf-294bb7d8bd03)


5. Resource Output:

   - Output the public IP of the web server EC2 instance.
![Screenshot 2024-02-16 202239](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/c0d7694b-c09c-4839-a524-f258cb90b79f)

![Screenshot 2024-02-16 202309](https://github.com/rk630/Orchestration_with_Terraform-Ansible/assets/139606316/eb71334c-c7f5-4941-9f88-a5be693e67c3)

Part 2: Configuration and Deployment with Ansible


1. Ansible Configuration:

   - Configure Ansible to communicate with the AWS EC2 instances.

2. Web Server Setup:

   - Write an Ansible playbook to install Node.js and NPM on the web server.

   - Clone the MERN application repository and install dependencies.

3. Database Server Setup:

   - Install and configure MongoDB on the database server using Ansible.

   - Secure the MongoDB instance and create necessary users and databases.

4. Application Deployment:

   - Configure environment variables and start the Node.js application.

   - Ensure the React frontend communicates with the Express backend.

5. Security Hardening:

   - Harden the security by configuring firewalls and security groups.

   - Implement additional security measures as needed (e.g., SSH key pairs, disabling root login).
