#!/bin/bash
sleep 5m
sudo su - root
# Install AWS EFS Utilities
apt-get -y install git binutils
git clone https://github.com/aws/efs-utils /home/ubuntu/utils
cd /home/ubuntu/utils
apt-get update
./build-deb.sh
apt-get -y install ./build/amazon-efs-utils*deb
# Mount EFS
mkdir /efs
efs_id="${efs_id}"
mount -t efs $efs_id:/ /efs
# Edit fstab so EFS automatically loads on reboot
echo $efs_id:/ /efs efs defaults,_netdev 0 0 >> /etc/fstab
