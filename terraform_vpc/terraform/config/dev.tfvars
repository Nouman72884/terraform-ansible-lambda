aws-region = "us-east-1"
amis = "ami-0ac80df6eff0e70b5"
vpc-cidr = "10.0.0.0/16"
public-subnet = ["10.0.1.0/24","10.0.2.0/24"]
private-subnet = ["10.0.3.0/24","10.0.4.0/24"]
aws-instance-type = "t2.micro"
keypair-name = "nouman_pk"
name = "nouman"
jenkins_url = "http://54.80.44.192/"
jenkins_username = "admin" 
jenkins_password = "55badced65dc43c69b8598516a4cd508"
jenkins_slave_nb_executor = "2"
jenkins_slave_home = "/var/jenkins_home"
jenkins_slave_user = "ubuntu"
jenkins_slave_group = "ubuntu"