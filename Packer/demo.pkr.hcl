data "aws_ami" "base_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.*.*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

source "amazon-ebs" "example" {
  region         = "ap-southeast-1"
  source_ami     = data.amazon-ami.base_image.id
  instance_type  = "t2.micro"
  ssh_username   = "ec2-user"
  ssh_agent_auth = false
  ami_name       = "hcp_packer_demo_app_{{timestamp}}"
}

build {
  amazon-ebs {
    bucket         = "github-oidc-aws-local-tfstates-lk"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    access_key     = "your-aws-access-key"
    secret_key     = "your-aws-secret-key"
    s3_endpoint    = "s3.amazonaws.com"
    s3_force_path_style = true

    // ... other configuration options for the Amazon EBS builder
  }

  sources = ["source.amazon-ebs.example"]

  // Create directories
  provisioner "shell" {
    inline = ["sudo mkdir /opt/webapp/"]
  }

  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      iteration_id = packer.iterationID
    }
  }
}
