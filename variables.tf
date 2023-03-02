variable "region" {
  description = "AWS Region"
  type = string
  sensitive = false
}

variable "vpc_cidr" {
  description = "CIDR block of VPC"
  type = string
  sensitive = false
}

variable "subnet_public-1" {
  description = "CIDR block of Public-1 subnet"
  type = map(string)
  sensitive = false
}

variable "subnet_public-2" {
  description = "CIDR block of Public-2 subnet"
  type = map(string)
  sensitive = false
}

variable "route_public_cidr" {
  description = "CIDR block of public route table"
  type = string
  sensitive = false
}


variable "key-name" {
  description = "Key Pair attach with Ec2"
  type = string
  sensitive = true
}


variable "rds" {
  description = "Values for RDS Database"
  type = map(string)
  sensitive = true
}


/* variable "ec2-sg" {
  description = "Key Pair attach with Ec2"
  type = map(string)
  sensitive = false
} */