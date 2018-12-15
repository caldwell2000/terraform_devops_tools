#!/bin/bash
sudo yum update -y
sudo yum install tcpdump telnet bind-utils wget zip unzip -y
echo "ATL_SSL_SELF_CERT_ENABLED=false" >>/etc/atl
/etc/init.d/atlbitbucket start
sleep 60
/opt/atlassian/bin/atl-update-host-name.sh
