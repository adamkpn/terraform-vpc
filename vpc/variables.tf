#----vpc/variables.tf-----

#----region----
variable "region" {
  type        = string
  description = "Region in which we would like to create our VPC"
}

#----vpc----
variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC"
}

#----vpc public subnets----
variable "vpc_subnet_cidr_public" {
  description = "Public Subnets"
  type        = list(string)
}

#----vpc private subnets----
variable "vpc_subnet_cidr_private" {
  description = "Private Subnets"
  type        = list(string)
}

#----ec2 counter----
variable "ec2_counter" {
  type        = number
  description = "Number of EC2 instances to create"
}

#----ec2 instance type----
variable "ec2_instance_type" {
  type        = string
  description = "Type of EC2 instance/s to create"
}

#----ec2 spot desired price----
variable "ec2_spot_price" {
  type        = string
  description = "Desired Spot price for EC2 instance"
}

#----ec2 name prefix----
variable "ec2_name_prefix" {
  type        = string
  description = "EC2 name prefix"
}

#----environment----
variable "env" {
  type        = string
  description = "Environment"
}