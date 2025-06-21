terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

provider "aws" {
   region     = "us-east-2"
   access_key = var.aws_access_key
   secret_key = var.aws_secret_key
}


resource "aws_vpc" "vpc-1" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}


# module for creating internet connection
module "myapp_subnets" {
  source              = "./modules/subnets"
  subnet-1_cidr_block = var.subnet-1_cidr_block
  subnet-2_cidr_block = var.subnet-2_cidr_block
  availability_zone   = var.availability_zone
  env_prefix          = var.env_prefix
  vpc_id              = aws_vpc.vpc-1.id


}


# module for creating ec2 for the main app
module "app_server" {
  source        = "./modules/webserver"
  my_ip         = var.my_ip
  env_prefix    = var.env_prefix
  vpc_id        = aws_vpc.vpc-1.id
  public_key    = var.public_key
  instance_type = var.instance_type
  subnet_id     = module.myapp_subnets.subnet-1.id 
}


# module for creating ec2 for database

module "database_server" {
  source = "./modules/Database" 
  public_key = var.public_key
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.vpc-1.id
  instance_type = var.instance_type
  subnet_id = module.myapp_subnets.subnet-2.id
  wordpress_sg = module.app_server.SG 
}







