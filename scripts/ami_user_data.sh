#!/bin/sh
TOKEN=`cat /home/ec2-user/token.txt`
cd /home/ec2-user
git clone https://${TOKEN}@github.com/saeedlk/infra-terraform.git
