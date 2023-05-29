provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  backend "s3" {
    bucket = "local-tfstate-lk"
    key    = "terraform2.tfstate"
    region = "ap-southeast-1"
  }
}
 
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
      name = "name"
      values = ["amzn-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "ec2_instance_lk" {
  # ami           = "ami-0b08bfc6ff7069aff"
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

#   vpc_security_group_ids = [aws_security_group.launch_wizard_lk.id]
  
  tags = {
    Name = "my-server-lk-2"
  }
}
