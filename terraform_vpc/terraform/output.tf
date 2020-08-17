output "vpc-id" {
  value = module.vpc.vpc-id
}
output "public-subnets-id" {
  value = module.vpc.public-subnets-id
}
output "private-subnets" {
  value = module.vpc.private-subnets
}
output "instance-security-group-id" {
  value = module.vpc.instance-security-group-id
}

# output "private-subnet-id-1" {
#   value = module.vpc.private-subnet-id-1
# }

