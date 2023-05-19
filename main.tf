provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-0b08bfc6ff7069aff"
  instance_type = "t2.micro"
  
  key_name      = "mumbai-ssh"
  
#   user_data = file("download_repo.sh")

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum update -y",
#       "sudo yum install -y git",
#       "git clone YOUR_REPO_URL /path/to/repository",
#       "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash",
#       "export NVM_DIR=\"$HOME/.nvm\"",
#       "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"",
#       "[ -s \"$NVM_DIR/bash_completion\" ] && \\. \"$NVM_DIR/bash_completion\"",
#       "nvm install node"
#     ]
#   }

  tags = {
    Name = "testlk"
  }
}