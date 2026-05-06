
locals {
  env = {
    dev = {
      instance_count        = 1
      
      vpc_cidr              = "10.0.0.0/16"
      public_subnet_1_cidr  = "10.0.1.0/24"
      public_subnet_2_cidr  = "10.0.2.0/24"
      private_subnet_1_cidr = "10.0.3.0/24"
      private_subnet_2_cidr = "10.0.4.0/24"

      bucket_count = 1
    }
    stg = {
      instance_count        = 2

      vpc_cidr              = "10.1.0.0/16"  
      public_subnet_1_cidr  = "10.1.1.0/24"
      public_subnet_2_cidr  = "10.1.2.0/24"
      private_subnet_1_cidr = "10.1.3.0/24"
      private_subnet_2_cidr = "10.1.4.0/24"

      bucket_count = 2
    }
    prd = {
      instance_count        = 3

      vpc_cidr              = "10.2.0.0/16"  
      public_subnet_1_cidr  = "10.2.1.0/24"
      public_subnet_2_cidr  = "10.2.2.0/24"
      private_subnet_1_cidr = "10.2.3.0/24"
      private_subnet_2_cidr = "10.2.4.0/24"

      bucket_count = 3
    }
  }
  current = lookup(local.env, terraform.workspace, local.env["dev"])
  ws      = terraform.workspace 
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block             = local.current.vpc_cidr
  public_subnet_1_cidr_block = local.current.public_subnet_1_cidr
  public_subnet_2_cidr_block = local.current.public_subnet_2_cidr
  private_subnet_1_cidr_block = local.current.private_subnet_1_cidr
  private_subnet_2_cidr_block = local.current.private_subnet_2_cidr

  vpc_name              = "${local.ws}-vpc"
  internet_gateway_name = "${local.ws}-igw"
  public_subnet_1_name  = "${local.ws}-public-subnet-1"
  public_subnet_2_name  = "${local.ws}-public-subnet-2"
  private_subnet_1_name = "${local.ws}-private-subnet-1"
  private_subnet_2_name = "${local.ws}-private-subnet-2"
  nat_eip_1_name        = "${local.ws}-nat-eip-1"
  nat_eip_2_name        = "${local.ws}-nat-eip-2"
  nat_gateway_1_name    = "${local.ws}-nat-1"
  nat_gateway_2_name    = "${local.ws}-nat-2"
  public_route_table_name      = "${local.ws}-public-rt"
  private_route_table_1_name   = "${local.ws}-private-rt-1"
  private_route_table_2_name   = "${local.ws}-private-rt-2"
}

module "s3" {
  source          = "./modules/s3"
  env             = terraform.workspace
  s3_bucket_count = local.current.bucket_count
}


module "ec2_public_1" {
  source             = "./modules/ec2"
  env                = local.ws
  ec2_instance_count = local.current.instance_count
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.public_subnet_ids[0] 
  name_suffix        = "pub-az1"                        
  depends_on         = [module.vpc]
}


module "ec2_private_1" {
  source             = "./modules/ec2"
  env                = local.ws
  ec2_instance_count = local.current.instance_count
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.private_subnet_ids[0] 
  name_suffix        = "prv-az1"
  depends_on         = [module.vpc]
}

module "ec2_public_2" {
  source             = "./modules/ec2"
  env                = local.ws
  ec2_instance_count = local.current.instance_count
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.public_subnet_ids[1]  
  name_suffix        = "pub-az2"
  depends_on         = [module.vpc]
}

module "ec2_private_2" {
  source             = "./modules/ec2"
  env                = local.ws
  ec2_instance_count = local.current.instance_count
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.private_subnet_ids[1] 
  name_suffix        = "prv-az2"
  depends_on         = [module.vpc]
}