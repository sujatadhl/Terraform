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
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "sujata_sc"
    }
}


#target group
resource "aws_lb_target_group" "sujata-tg" {
 name     = "sujata-tg"
 port     = 80
 protocol = "HTTP"
 vpc_id   = aws_vpc.sujata_vpc.id

 health_check {
 enabled = true
 port = 80
 interval = 30
 protocol = "HTTP"
 path = "/"
 matcher = "200"
 healthy_threshold = 3
 unhealthy_threshold = 2
 }
}

resource "aws_lb_target_group_attachment" "sujata_tg_attach" {
  target_group_arn = aws_lb_target_group.sujata-tg.arn
  target_id        =  aws_autoscaling_attachment..id
  port             = 80
}


#application load balancer

resource "aws_lb" "sujata-alb" {
 name               = "sujata-alb"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [aws_security_group.sujata_sc.id]
 subnets            = aws_subnet.public_subnet[*].id
}

resource "aws_lb_listener" "sujata-lb-listener" {
 load_balancer_arn = aws_lb.sujata-alb.arn
 port = 80
 protocol = "HTTP"  

 default_action {
    type = "redirect" 
    redirect {
        host = "#{host}"
        port = 443
        protocol = "HTTPS"
        status_code = "HTTP_301"
    }
    target_group_arn = aws_lb_target_group.sujata-tg.arn

 }
}

resource "aws_launch_template" "sujata-template" {
  name             = "sujata-template"
  image_id         = var.ami_id
  instance_type    = var.instance_type
  key_name         = var.ami_key_pair_name
  network_interfaces {
  associate_public_ip_address = true  
  security_groups    = [aws_security_group.sujata_sc.id]  
  }
}

resource "aws_autoscaling_group" "sujata-acg" {
  name = "sujata-acg"
  desired_capacity    = 3   
  max_size            = 3
  min_size            = 2
  
  vpc_zone_identifier = aws_subnet.public_subnet[*].id
  target_group_arns   = [aws_lb_target_group.sujata-tg.arn]

  launch_template {
    id      = aws_launch_template.sujata-template.id
    version = aws_launch_template.sujata-template.latest_version
  }
}

resource "aws_autoscaling_policy" "sujata-asg-policy" {
  name                   = "sujata-asg-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.sujata-acg.name
}


# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "sujata-acg-attach" {
  autoscaling_group_name = aws_autoscaling_group.sujata-acg.id
  lb_target_group_arn    = aws_lb_target_group.sujata-tg.arn
  }
