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

#ec2 in public subnet
resource "aws_instance" "ec2_sujata" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet[0].id
  key_name    = var.ami_key_pair_name
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.sujata_sc.id]

  tags = {
        Name = "ec2_sujata"
    }
}

resource "aws_db_subnet_group" "sujata_db_subnet" {
    subnet_ids = aws_subnet.private_subnet[*].id
    tags = {
        Name = "sujata_db_subnet"
    }
}

#rds in private subnet
resource "aws_db_instance" "sujata-db" {
  allocated_storage = 10
  storage_type = var.storage_type
  engine = var.engine
  instance_class = var.instance_class
  identifier = "sujatadb"   
  username = "sujj"
  password = "password"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.sujata_rds_sg.id] 
  db_subnet_group_name = aws_db_subnet_group.sujata_db_subnet.name
  tags = {
        Name = "sujata_db"
    }
}

resource "aws_security_group" "sujata_rds_sg" {
  name = "sujata_rds_sg"  
  vpc_id = aws_vpc.sujata_vpc.id
   ingress {
     from_port   = 3306
     to_port     = 3306
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

}





