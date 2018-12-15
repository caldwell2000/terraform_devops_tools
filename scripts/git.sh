#!/bin/bash
/sbin/mkfs.xfs /dev/nvme1n1
mkdir /data1
/bin/mount /dev/nvme1n1 /data1
echo /dev/nvme1n1  /data1 xfs defaults,nofail 0 2 >> /etc/fstab

sudo yum update -y
sudo yum install tcpdump telnet bind-utils wget zip unzip -y
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
sudo yum install tcpdump telnet bind-utils wget -y
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install pygpgme yum-utils
sudo EXTERNAL_URL="http://localhost" yum install -y gitlab-ce
sudo yum install -y git
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
#sudo /bin/gitlab-ctl reconfigure
