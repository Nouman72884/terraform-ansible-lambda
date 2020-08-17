output "vpc-id"{
  value = aws_vpc.vpc.id
}
output "public-subnets" {
  value = aws_subnet.public-subnets.*.id
}
output "private-subnets" {
  value = aws_subnet.private-subnets.*.id
}
output "instance-security-group-id" {
  value = aws_security_group.instance-security-group.id
}
output "private-subnets-id" {
  value = aws_subnet.private-subnets[0].id
}
output "public-subnets-id" {
  value = aws_subnet.public-subnets[0].id
}

