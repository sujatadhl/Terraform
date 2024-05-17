#vpc
resource "aws_vpc" "sujata_vpc" { 
    cidr_block = var.cidr_value

    tags = {
        Name = "sujata-vpc"
    }
}

#public_subnet
resource "aws_subnet" "public_subnet" { 
    count      = length(var.public_subnets) 
    vpc_id     = aws_vpc.sujata_vpc.id 
    cidr_block = element(var.public_subnets, count.index)
    availability_zone = element(var.azs, count.index)

    tags = {   
        Name = "Public Subnet ${count.index + 1}" 
        }
    }
#private_subnet
resource "aws_subnet" "private_subnet" { 
    count      = length(var.private_subnets) 
    vpc_id     = aws_vpc.sujata_vpc.id 
    cidr_block = element(var.private_subnets, count.index)
    availability_zone = element(var.azs, count.index)

 tags = {   
    Name = "Private Subnet ${count.index + 1}" 
    }
}
#internet_gateway
resource "aws_internet_gateway" "sujata_gw" {
 vpc_id = aws_vpc.sujata_vpc.id
 tags = {
    Name = "sujata_gw"
 }
}

#elastic_ip 
resource "aws_eip" "eip_sujata" {
    domain = "vpc"
tags = {
    Name = "eip_sujata"
 } 
}

#nat
resource "aws_nat_gateway" "sujata_nat" {
allocation_id = aws_eip.eip_sujata.id
subnet_id   = aws_subnet.public_subnet[0].id
 tags = {
    Name = "sujata_nat"
 }
}

#public_route_table
resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.sujata_vpc.id
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.sujata_gw.id
    }
    tags = {
        Name = "public-route-table"
    }
}

#private_route_table
resource "aws_route_table" "private-route-table" {
    vpc_id = aws_vpc.sujata_vpc.id
     route {
        cidr_block = "0.0.0.0/0" 
        nat_gateway_id = aws_nat_gateway.sujata_nat.id
    }
    tags = {
        Name = "private-route-table"
    }
}

#public_subnet_association
resource "aws_route_table_association" "public_subnet_association" {
 count = length(var.public_subnets)
 subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
 route_table_id = aws_route_table.public-route-table.id
}

#private_subnet_association
resource "aws_route_table_association" "private_subnet_association" {
 count = length(var.private_subnets)
 subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
 route_table_id = aws_route_table.private-route-table.id
}

#security_group
resource "aws_security_group" "sujata_sc" {
    vpc_id = aws_vpc.sujata_vpc.id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "sujata_sc"
    }
}







