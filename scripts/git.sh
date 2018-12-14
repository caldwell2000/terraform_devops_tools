#!/bin/bash
sudo yum update -y
sudo yum install unzip
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
sudo yum install tcpdump telnet bind-utils -y
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install pygpgme yum-utils
sudo EXTERNAL_URL="http://localhost" yum install -y gitlab-ce
sudo yum install -y git
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
