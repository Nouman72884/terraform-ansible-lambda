#!/bin/bash
apt-get update -y
apt-get upgrade -y
apt install default-jre -y
#apt-get install unzip -y
#curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#unzip awscliv2.zip
#sudo ./aws/install
mkdir -p /var/jenkins_home
chown -R ubuntu:ubuntu /var/jenkins_home
jenkins_slave_home=/var/jenkins_home
jenkins_slave_nb_executor=1
jenkins_slave_java=/usr/bin/java
JENKINS_RUN=/var/jenkins_home
INSTANCE_NAME=$(curl -s 169.254.169.254/latest/meta-data/local-hostname)
echo "instance name is: $INSTANCE_NAME"
INSTANCE_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)
JENKINS_URL="http://54.80.44.192/"
JENKINS_USERNAME="admin"
JENKINS_PASSWORD="55badced65dc43c69b8598516a4cd508"
TOKEN=$(curl -u $JENKINS_USERNAME:$JENKINS_PASSWORD ''$JENKINS_URL'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
echo "token is: $TOKEN"
curl -v -u $JENKINS_USERNAME:$JENKINS_PASSWORD -H "$TOKEN" -d 'script=
import hudson.model.Node.Mode
import hudson.slaves.*
import jenkins.model.Jenkins

DumbSlave dumb = new DumbSlave("'$INSTANCE_NAME'",
"'$INSTANCE_NAME'",
"'$JENKINS_RUN'",
"'$jenkins_slave_nb_executor'",
Mode.NORMAL,
"ec2-fleet",
new JNLPLauncher(),
RetentionStrategy.INSTANCE)
Jenkins.instance.addNode(dumb)
' $JENKINS_URL/script
SECRET=$(curl -L -s -u  "$JENKINS_USERNAME":"$JENKINS_PASSWORD" -H   "$TOKEN"  "$JENKINS_URL"/computer/$INSTANCE_NAME/slave-agent.jnlp | sed "s/.*<application-desc main-class=\"hudson.remoting.jnlp.Main\"><argument>\([a-z0-9]*\).*/\1/")
echo "secret is: $SECRET"
jenkins_slave_java=/usr/bin/java
wget -q -O "$JENKINS_RUN"/slave.jar $JENKINS_URL/jnlpJars/slave.jar
$jenkins_slave_java -jar "/var/jenkins_home"/slave.jar -jnlpUrl $JENKINS_URL/computer/$INSTANCE_NAME/slave-agent.jnlp -secret $SECRET  -workDir "$jenkins_slave_home"