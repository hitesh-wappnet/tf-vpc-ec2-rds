terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>4.55"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    "Name" : "tf-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name: "tf-IgW"
  }
}

resource "aws_subnet" "public-1" {
  cidr_block = var.subnet_public-1.cidr
  availability_zone = var.subnet_public-1.availability_zone
  vpc_id = aws_vpc.this.id
  map_public_ip_on_launch= true
  tags = {
    Name: "tf-subnet-public-1"
  }
}

resource "aws_subnet" "public-2" {
  cidr_block = var.subnet_public-2.cidr
  availability_zone = var.subnet_public-2.availability_zone
  vpc_id = aws_vpc.this.id
  map_public_ip_on_launch= true
  tags = {
    Name: "tf-subnet-public-2"
  }
}


resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.route_public_cidr
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    "Name" = "tf-public-route"
  }
}

resource "aws_route_table_association" "this" {
  route_table_id = aws_route_table.public-route.id
  subnet_id = aws_subnet.public-1.id
}

resource "aws_route_table_association" "this-2" {
  route_table_id = aws_route_table.public-route.id
  subnet_id = aws_subnet.public-2.id
}

################### EC2 Instance ####################

/* resource "aws_key_pair" "this" {
  key_name = "tf-local"
  public_key = var.key
  
} */


resource "tls_private_key" "rsa-4096-example" {
  algorithm = "RSA"
  rsa_bits  = 4096
  provisioner "local-exec" {
    command = <<-EOT
        echo "${tls_private_key.rsa-4096-example.private_key_pem}" > "${var.key-name}.pem"
        chmod 600 "${var.key-name}.pem"
        EOT
  }
}

resource "aws_key_pair" "name" {
  key_name = var.key-name
  public_key = tls_private_key.rsa-4096-example.public_key_openssh
  
}


resource "aws_security_group" "this" {
    name = "SG for EC2"
    description = "Allowing rules"
    vpc_id = aws_vpc.this.id

    ingress {
        description = "Allowing SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allowing HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow all"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name: "tf-Security"
    }
}

resource "aws_instance" "name" {
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public-1.id
  ami = data.aws_ami.aws_ubuntu_latest.id
  key_name = var.key-name
  vpc_security_group_ids = [aws_security_group.this.id]
  user_data = "${file("web.sh")}"
  disable_api_termination = true

  tags = {
    "Name" = "tf-instance"
  }
}

output "Ec2-Ip" {
  value = aws_instance.name.public_ip
}


############### RDS INSTANCE ###################
resource "aws_security_group" "rds" {
  name = "db-SG"
  vpc_id =  aws_vpc.this.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}


resource "aws_db_subnet_group" "name" {
  subnet_ids = ["${aws_subnet.public-1.id}",aws_subnet.public-2.id]
  name = "db-subnet-group"
}


resource "aws_db_instance" "name" {
  engine = var.rds.engine
  engine_version = var.rds.engine_version
  instance_class = var.rds.instance_class
  identifier = var.rds.identifier
  username = var.rds.username
  password = var.rds.password
  allocated_storage = var.rds.allocated_storage
  vpc_security_group_ids = [ aws_security_group.rds.id ]
  db_name = var.rds.db_name
  db_subnet_group_name = aws_db_subnet_group.name.name
  publicly_accessible = true
  performance_insights_enabled = false
  deletion_protection = false
  skip_final_snapshot = true
}



output "rds-url" {
  value = aws_db_instance.name.address
}


data "aws_availability_zones" "available" {
  state = "available"
}

output "azss" {
  value = [for name in data.aws_availability_zones.available.names : "hehe ${name}"]

}

output "a2" {
  value = data.aws_availability_zones.available.names[1]
}

output "a3" {
  value = data.aws_availability_zones.available.names[2]
}

/* resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.this.id

  route = [{
    cidr_block = "10.25.0.0/16"
  },{
    cidr_block = "0.0.0.0/0"
    gate
  }
  ] 
} */



/* resource "aws_route_table" "example" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    cidr_block = aws_vpc.this.cidr_block
  }

  tags = {
    Name = "example"
  }
} */
