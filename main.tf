provider "aws" {
  region = "eu-central-1"
}

module "myapp-vpc" {
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  env_prefix = var.env_prefix
}

module "myapp-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = module.myapp-vpc.vpc.id
  default_route_table_id = module.myapp-vpc.vpc.default_route_table_id
}

module "myapp-server" {
  source = "./modules/webserver"
  vpc_id = module.myapp-vpc.vpc.id  
  my_ip = var.my_ip   
  env_prefix = var.env_prefix
  image_name = var.image_name
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet.id 
  avail_zone = var.avail_zone
}




