data "aws_ami" "aws_ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical owner ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_ami_ids" "aws_ubuntu_latest_ids" {
  owners = ["099720109477"] # Canonical owner ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

