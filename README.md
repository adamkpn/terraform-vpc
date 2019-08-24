# VPC module

### This Terraform (VPC) module will spin up the following infrastructure:
- VPC (public and private subnet)
- 3 x t2.micro Ubuntu instances in private subnet in an auto scaling group – desired state of 3 by using the spot instances
- Each instance will have the “Name” tag with unique value of “micro-<instance-number>” (instance number = 1..3)
- Create Application Load Balancer forwarding network traffic to the aforementioned instances
- The following services will be preinstalled on each instance: chrony, unzip, python
  - I've added the "Nginx" package on each server, to allow simple check with the Application Load Balancer
- Create an s3 bucket  - the name is unimportant
- The instances will have a read only access to this bucket

##### Module Inputs:
- Please find the list of arguments you will need to specify to the module
module "vpc" {
  source                  = "./vpc"
  region                  = "us-east-1"
  env                     = "test"
  vpc_cidr                = "10.0.0.0/16"
  vpc_subnet_cidr_public  = ["10.0.11.0/24", "10.0.12.0/24"]
  vpc_subnet_cidr_private = ["10.0.111.0/24"]
  ec2_counter             = 3
  ec2_instance_type       = "t2.micro"
  ec2_spot_price          = "0.0035"
  ec2_name_prefix         = "micro"
}

- Please note that you will need to specify at least 2 "Public" CIDR ranges for the "vpc_subnet_cidr_public" variable, otherwise "AWS ALB/LB" will bring errror (the requirements for the deply by the AWS is a minimum of 2 x Availability Zones)

##### Module Outputs:
- On success, module will provide two Outputs:
  - DNS name of "Application Load Balancer" (so you could check the deployment)
  - DNS name of "S3 Bucket"
Outputs:
alb_dns_name = micro-alb-1629301761.us-east-1.elb.amazonaws.com
s3_bucket_domain_name = tf-s3-test-micro-bucket.s3.amazonaws.com
