provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "github-oidc-aws-local-tfstates-lk"
    key    = "terraform.tfstate"
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

resource "aws_instance" "ec2_instance" {
  # ami           = "ami-0b08bfc6ff7069aff"
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

#   vpc_security_group_ids = [aws_security_group.launch_wizard_lk.id]

  key_name      = "singapore-ssh"
  
    user_data = <<-EOF
      #!/bin/bash
      sleep 300  # Wait for instance to fully initialize
      timestamp=$(date +%Y-%m-%d_%H-%M-%S)
      image_name="myImageName_${timestamp}"
      instance_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=ws-tunnel-" --query "Reservations[].Instances[].InstanceId" --output text)
      aws ec2 create-image --instance-id $instance_id --name "${image_name}" --region ap-south-1 --description "Image created from my tunnio-infra workflow" --output json
    EOF
  
  
  tags = {
    Name = "ws-tunnel-"
  }
}
