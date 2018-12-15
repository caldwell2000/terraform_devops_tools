#!/bin/bash

#Mount EBS Volume and make XFS Filesystem
/sbin/mkfs.xfs /dev/nvme1n1
mkdir /data1
/bin/mount /dev/nvme1n1 /data1
echo /dev/nvme1n1  /data1 xfs defaults,nofail 0 2 >> /etc/fstab

echo "Install OS Patches"
sudo yum update -y

echo "Install common tools"
sudo yum install tcpdump telnet bind-utils wget zip unzip -y
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
sudo yum install tcpdump telnet bind-utils wget -y
sudo yum install pygpgme yum-utils

echo "Install Jenkins stable release"
yum remove -y java
yum install -y java-1.8.0-openjdk
JAVA_HOME=/usr/lib/jvm/; export JAVA_HOME
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install -y jenkins
chkconfig jenkins on

echo "Install Telegraf"
wget https://dl.influxdata.com/telegraf/releases/telegraf-1.6.0-1.x86_64.rpm -O /tmp/telegraf.rpm
yum localinstall -y /tmp/telegraf.rpm
rm /tmp/telegraf.rpm
chkconfig telegraf on
mv /tmp/telegraf.conf /etc/telegraf/telegraf.conf
service telegraf start

echo "Install Groovy"
curl -s get.sdkman.io | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install groovy
groovy -version

echo "Install Docker engine"
yum update -y
yum install docker -y
usermod -aG docker ec2-user
service docker start

echo "Install git"
yum install -y git

echo "Setup SSH key"
mkdir /var/lib/jenkins/.ssh
touch /var/lib/jenkins/.ssh/known_hosts
chown -R jenkins:jenkins /var/lib/jenkins/.ssh
chmod 700 /var/lib/jenkins/.ssh
mv /tmp/id_rsa /var/lib/jenkins/.ssh/id_rsa
chmod 600 /var/lib/jenkins/.ssh/id_rsa

echo "Configure Jenkins"
mkdir -p /var/lib/jenkins/init.groovy.d
mv /tmp/basic-security.groovy /var/lib/jenkins/init.groovy.d/basic-security.groovy
mv /tmp/disable-cli.groovy /var/lib/jenkins/init.groovy.d/disable-cli.groovy
mv /tmp/csrf-protection.groovy /var/lib/jenkins/init.groovy.d/csrf-protection.groovy
mv /tmp/disable-jnlp.groovy /var/lib/jenkins/init.groovy.d/disable-jnlp.groovy
mv /tmp/jenkins.install.UpgradeWizard.state /var/lib/jenkins/jenkins.install.UpgradeWizard.state
mv /tmp/node-agent.groovy /var/lib/jenkins/init.groovy.d/node-agent.groovy
chown -R jenkins:jenkins /var/lib/jenkins/jenkins.install.UpgradeWizard.state
mv /tmp/jenkins /etc/sysconfig/jenkins
chmod +x /tmp/install-plugins.sh
bash /tmp/install-plugins.sh
service jenkins start
