cidr_value = "12.0.0.0/16"
azs = ["us-east-2a", "us-east-2b"]
public_subnets = ["12.0.1.0/24", "12.0.2.0/24"]
private_subnets = ["12.0.11.0/24", "12.0.12.0/24"]

instance_type = "t2.micro"
ami_id = "ami-09040d770ffe2224f"
ami_key_pair_name = "sujata-ohio"

engine = "mysql"
instance_class = "db.c6gd.medium"
storage_type = "gp2"

