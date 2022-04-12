[![Typing SVG](https://readme-typing-svg.herokuapp.com?color=F76C00&lines=AWS+EC2+Deployment+with+Terraform)](https://git.io/typing-svg)

This repository provides EC2 instance deployment using AWS EC2 service with Terraform.

![](src/terraform.png =250x250)) ![](src/aws.png =250x250))

### Parts of this repository ###
* [Main.tf](https://github.com/elif-apaydin/terraform-aws-ec2/tree/main/main.tf)
* [Bitbucket Pipeline](https://github.com/elif-apaydin/terraform-aws-ec2/tree/main/bitbucket-pipelines.yml)

This configuration will deploy EC2 Instance. Change these variables for deployment.

```
app_tags            = "value" (APP_TAGS value for the EC2 resources)

region              = "value" (us-east-1 or eu-central-1)

ec2_type            = "value" (Instance type for the EC2 Instances. e.g. t3.micro)

vpc_id              = "value" (VPC ID for the EC2. Every application has to be in its own VPC. Also VPC should exist too before this deployment.)

ec2_subnets         = "value" (Subnet id for the where the instances should exist)

keypair             = "value" (Keypair for the EC2 Instance. Each application must have its own keypair. Create keypair on the EC2 console and write the name of that keypair here. Name must be the same as **app_tags value**)

instance_profile    = "value" (Instance profile for the instances. If doesn't exist you should create it before this deployment. You can create on IAM folder on this repository)

disc_size           = number (Disc size for the EC2 Instance. It should be at least 10 GB)

sg_ports            = 443 (It must be HTTPS not HTTP port.)

email_sns_topic     = "value" (Email alarm sns topic arn)

```