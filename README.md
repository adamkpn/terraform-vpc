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
