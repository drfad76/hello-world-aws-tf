terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider

provider "aws" {
  region = "ap-southeast-2" 
}

data "aws_ami" "instance_id" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "terraform-ec2" {
  ami               = data.aws_ami.instance_id.id
  instance_type     = "t2.micro"
  availability_zone = "ap-southeast-2a"
  security_groups   = [aws_security_group.allow_web.name]

  user_data         = <<-EOF
                #! /bin/bash
                sudo yum update
                sudo yum install -y httpd
                sudo systemctl start httpd
                sudo systemctl enable httpd
                echo "
<h1>Hello World!</h1>

" | sudo tee /var/www/html/index.html
        EOF
  tags = {
    Name = "Created by Terraform"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web.traffic"
  description = "Allow web traffic"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" //any protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Created by Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
     alarm_name                = "cpu-utilization"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "2"
     metric_name               = "CPUUtilization"
     namespace                 = "AWS/EC2"
     period                    = "120" 
     statistic                 = "Average"
     threshold                 = "80"
     alarm_description         = "Web server cpu utilization monitoring"
     insufficient_data_actions = []
dimensions = {
       InstanceId = aws_instance.terraform-ec2.id
     }
}

output "instance_ips" {
  value = ["${aws_instance.terraform-ec2.*.public_ip}"]
}

output "instance_dns" {
  value = ["${aws_instance.terraform-ec2.*.public_dns}"]
}
