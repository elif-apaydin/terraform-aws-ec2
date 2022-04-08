provider "aws" {
  region = var.region
}

data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

data "aws_availability_zones" "available" {
		  state = "available"
		}

data "aws_subnet_ids" "subnets_id" {
  vpc_id = var.vpc_id
}

resource "aws_instance" "EC2" {
  ami = data.aws_ami.amazon-2.id
  availability_zone = "eu-central-1b"
  instance_type = var.ec2type
  tags = {
    Name = var.app_tags
    APP_NAME = var.app_tags
  }
  subnet_id = var.subnet
  key_name = var.keypair
  disable_api_termination = true
  iam_instance_profile = var.instanceprofile
  security_groups = [ aws_security_group.EC2_SG.id ]
  user_data = file("install_cloudwatch_agent.sh")
  root_block_device {
    volume_type = "gp3"
    volume_size = var.discsize
    throughput  = 125
    iops = 3000
    tags = {
        Name = var.app_tags
        APP_NAME = var.app_tags
      }
    }
  
}


resource "aws_eip" "EIP" {
  instance = aws_instance.EC2.id
  tags = {
    Name = var.app_tags
    APP_NAME = var.app_tags
  }
}

resource "aws_security_group" "EC2_SG" {
  name = "${var.app_tags}-EC2"
  vpc_id = var.vpc_id
  ingress = [
    {
    description = "Office"
    from_port = var.sgports
    to_port = var.sgports
    protocol = "tcp"
    cidr_blocks = ["<IP_ADRESS/32>"]
    self = null
    ipv6_cidr_blocks = null
    prefix_list_ids = null
    security_groups = null
    }
  ]

  egress = [
    {
    description = null
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self = null
    ipv6_cidr_blocks = null
    prefix_list_ids = null
    security_groups = null
    }
  ]

  tags = {
    Name = "${var.app_tags}-EC2"
    APP_NAME = var.app_tags
  }
}


resource "aws_cloudwatch_metric_alarm" "CPUAlert" {
  alarm_name                = "EC2 - ${var.app_tags} - CPUUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_actions             = [var.emailsnstopic]
  dimensions = {
        InstanceId = aws_instance.EC2.id
      }
  tags = {
    APP_NAME = var.app_tags
  }
}

resource "aws_cloudwatch_metric_alarm" "DiskAlert" {
  alarm_name                = "EC2 - ${var.app_tags} - DiskUsage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = "${var.app_tags} - Worker - Network Out"
  alarm_actions             = [var.opsgeniesnstopic]
  dimensions = {
        InstanceId = aws_instance.EC2.id
        ImageId    = data.aws_ami.amazon-2.id
        path                      = "/"
        InstanceType  = var.ec2type
        device        = "nvme0n1p1"
        fstype           = "xfs"
      }
  tags = {
    APP_NAME = var.app_tags
  }
}

resource "aws_cloudwatch_metric_alarm" "NetworkAlert" {
  alarm_name                = "EC2 - ${var.app_tags} - NetworkOut"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "NetworkOut"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "300000000"
  alarm_description         = "${var.app_tags} - Worker - Network Out"
  alarm_actions             = [var.opsgeniesnstopic]
  dimensions = {
        InstanceId = aws_instance.EC2.id
      }
  tags = {
    APP_NAME = var.app_tags
  }
}

resource "aws_cloudwatch_metric_alarm" "StatusAlert" {
  alarm_name                = "EC2 - ${var.app_tags} - StatusCheckFailed_Instance"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "StatusCheckFailed_Instance"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "${var.app_tags} - StatusCheckFailed_Instance"
  alarm_actions             = [var.opsgeniesnstopic]
  dimensions = {
        InstanceId = aws_instance.EC2.id
      }
  tags = {
    APP_NAME = var.app_tags
  }
}

output "EIP" {
  value = aws_eip.EIP.public_ip
}
