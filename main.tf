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
  
  provisioner "local-exec" {
    command = <<EOT
      sleep 300  # Wait for instance to fully initialize
      AMI_ID=$(aws ec2 create-image --instance-id ${self.id} --name "my-custom-image" --description "Custom image created by Terraform" --output text)
      echo "ami_id=${AMI_ID}" > ami_id.txt
      terraform output ami_id
    EOT
  }
  
  tags = {
    Name = "ws-tunnel-"
  }
}

output "ami_id" {
  value = file("ami_id.txt")
}
