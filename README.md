# terraform-ansible-lambda
This task has multiple parts
1.create vpc,autoscaling group(for jenkins slaves),ec2 public instance(for jenkins) using terraform
2.configure jenkins on ec2 instance using Ansible
3.install ec2-fleet-plugin for to create jenkins slaves when a new job is run
4.install strict-crumb-issuer plugin to issue jenkins crumb token
5.ec2-fleet-plugin has a bug.it does not scale down idle jenkins node it set instance protection on ec2 instance.to remove instance protection for scale down i have used 
lambda function.jenkins_restfull_api(http://ec2-54-159-72-182.compute-1.amazonaws.com/computer/api/json?pretty=true),boto3 describe_instances and set_instance_protection are used 
in lambda function.
jenkins_restfull_api is used to parse json for node names and their idle values.
jenkins slaves are configures using userdata in autoscaling group.
