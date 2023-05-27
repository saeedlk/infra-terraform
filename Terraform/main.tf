# provider "aws" {
#   region = "ap-south-1"
# }

variable "iteration_id" {
  description = "HCP Packer Iteration ID"
}

data "hcp_packer_image" "amazon_linux" {
  bucket_name    = "hcp-packer-demo"
  cloud_provider = "aws"
  iteration_id   = var.iteration_id
  region         = "ap-south-1"
}

resource "aws_security_group" "http_8080" {
  description = "Allow inbound TCP traffic to port 8080"

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


