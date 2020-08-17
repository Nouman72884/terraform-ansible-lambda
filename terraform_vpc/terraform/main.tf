module "vpc" {
  source = "./modules/vpc"
  aws-region = var.aws-region
  vpc-cidr = var.vpc-cidr
  public-subnet = var.public-subnet
  private-subnet = var.private-subnet
  name = var.name
}
module "ec2-instance" {
  source = "./modules/ec2-instance"
  public-subnets-id = module.vpc.public-subnets-id
  vpc-id = module.vpc.vpc-id
  instance-security-group-id = [module.vpc.instance-security-group-id]
  keypair-name = var.keypair-name
  aws-region = var.aws-region
  amis = var.amis
  aws-instance-type = var.aws-instance-type
  name = var.name
}
module "autoscaling" {
  source = "./modules/autoscaling"
  keypair-name = var.keypair-name
  amis = var.amis
  aws-region     = var.aws-region
  aws-instance-type = var.aws-instance-type
  private-subnets = module.vpc.private-subnets
  instance-security-group-id = module.vpc.instance-security-group-id
  jenkins_url=var.jenkins_url
  jenkins_username=var.jenkins_username
  jenkins_password=var.jenkins_password
  jenkins_slave_nb_executor=var.jenkins_slave_nb_executor
  jenkins_slave_home=var.jenkins_slave_home
  jenkins_slave_user=var.jenkins_slave_user
  jenkins_slave_group=var.jenkins_slave_group
  name = var.name
}
module "lambda_function" {
  source = "./modules/lambda_function"
  lambda_role = module.lambda_iamrole.lambda_role
}
module "lambda_iamrole" {
  source = "./modules/lambda_iamrole"
}