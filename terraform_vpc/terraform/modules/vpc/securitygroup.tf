resource "aws_security_group" "instance-security-group" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${terraform.workspace}-${var.name}-SG"
  description = "security group that allows all ingress and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #security_groups = [aws_security_group.alb-security-group.id]
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${terraform.workspace}-${var.name}-SG"
  }
}



