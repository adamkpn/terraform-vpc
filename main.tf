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
