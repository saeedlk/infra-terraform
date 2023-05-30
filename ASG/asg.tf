provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  backend "s3" {
    bucket = "local-tfstate-lk"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# data "terraform_remote_state" "tfstate_lk" {
#   backend = "s3"
#   config = {
#     bucket = "local-tfstate-lk"
#     key    = "terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }

# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]
  
#   filter {
#       name = "name"
#       values = ["amzn-ami-hvm-*-x86_64-ebs"]
#   }
# }

resource "aws_launch_template" "ec2_instance" {
  # name_prefix = "tunnel-"
  image_id = var.image_id
  # image_id = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.sec_lk.id]
  # vpc_security_group_ids = [aws_security_group.launch_wizard_lk.id]
  # vpc_security_group_ids = [data.terraform_remote_state.tfstate_lk.resources.instances.?.security_group_id]
  
#   key_name = "singaapore-ssh"

  # ebs_optimized = true

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "serverlk-${timestamp()}"
    }
  }
}

resource "aws_security_group" "sec_lk" {
  name        = "lk-sec-group"

  # Inbound Rules
  ingress {
    from_port   = 7070
    to_port     = 7070
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "lk-admin"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# output "instance_id" {
#   value = aws_launch_template.ec2_instance.latest_version.arn
# }

# output "ami_id" {
#   value = aws_instance.ec2_instance.ami_id
# }

# output "vpc_security_group_ids" {
#   value = aws_security_group.sec_lk.id
# }


# Create an Auto Scaling Group
resource "aws_autoscaling_group" "my_asg-lk" {
  name                      = "asg-lk"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  # launch_configuration      = aws_launch_configuration.my_lc.name
  # vpc_zone_identifier       = ["subnet-12345678"]  # Update with your subnet ID(s)
  availability_zones = [ "ap-southeast-1a", "ap-southeast-1b" ]
# Define the health check type and grace period
  health_check_type         = "ELB"
  health_check_grace_period = 300
  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
  launch_template {
    id      = aws_launch_template.ec2_instance.id
    version = "$Latest"
  }
}




# # Create a Launch Configuration
# resource "aws_launch_configuration" "my_lc" {
#   name                 = "my-lc"
# #   image_id             = "ami-12345678"  # Pass the AMI ID that is created through the workflow
#   image_id             = data.terraform_remote_state.tfstate-lk.outputs.ami_id
#   instance_type        = "t2.micro" 
#   security_groups      = data.terraform_remote_state.tfstate-lk.outputs.security_group_id
#   key_name             = "mumbai-ssh"  

#   # # Define any additional user data or configuration
#   # user_data = <<-EOF
#   #   # Additional user data or configuration goes here
#   # EOF
# }

# # Create a Scaling Policy
# resource "aws_autoscaling_policy" "my_policy-lk" {
#   name                   = "policy-lk"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.my_asg-lk.name
# }

# # Attach the Scaling Policy to the Auto Scaling Group
# resource "aws_autoscaling_attachment" "my_attachment" {
#   # policy_arn         = aws_autoscaling_policy.my_policy-lk.arn
#   autoscaling_group_name = aws_autoscaling_group.my_asg-lk.name
#   # lb_target_group_arn = aws_lb_target_group.testlk.arn
# }