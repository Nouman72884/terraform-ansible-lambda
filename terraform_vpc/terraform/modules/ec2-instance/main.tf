resource "aws_instance" "ec2-instance" {
  ami           = var.amis
  instance_type = var.aws-instance-type
  tags = {
    Name = "${terraform.workspace}-${var.name}-instance"
  }
  # the VPC subnet
  subnet_id =  var.public-subnets-id

  # the security group
  vpc_security_group_ids = var.instance-security-group-id

  # the public SSH key
  key_name = var.keypair-name
}