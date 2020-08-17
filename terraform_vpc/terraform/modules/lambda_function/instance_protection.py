import json
import boto3,time
from botocore.vendored import requests


def lambda_handler(event, context):
    username = 'admin'
    password = '55badced65dc43c69b8598516a4cd508'
    url = 'http://54.80.44.192/computer/api/json?pretty=true'
    source = requests.get(url,auth=(username,password))
    data = json.loads(source.content)
    print('printing idle values')
    for value in data['computer']:
        node_name=value['displayName']
        print(node_name)
        idle_value=value['idle']
        print(idle_value)
        client = boto3.client('ec2')
        response = client.describe_instances(
        Filters=[
            {
                'Name': 'private-dns-name',
                'Values': [node_name]
            },
        ],
        )
        for r in response['Reservations']:
            for i in r['Instances']:
                print('instance id of node')
                instanceid=i['InstanceId']
                print(instanceid)
                
                asg_client = boto3.client('autoscaling')
                asg =   "default-nouman-autoscaling-group"
                if idle_value == True:
                    res = asg_client.set_instance_protection(
                            InstanceIds=[instanceid],
                            AutoScalingGroupName= asg,
                            ProtectedFromScaleIn=False
                    
              )
                else:
                    res = asg_client.set_instance_protection(
                            InstanceIds=[instanceid],
                            AutoScalingGroupName= asg,
                            ProtectedFromScaleIn=True
                    )
    