#!/bin/bash

set -e

# if set will not create store history
set +o history


sudo -s -- <<EOF

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install unzip

EOF

#######################
# Install Packer 
#######################

PACKER_VER="1.4.4"
wget https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_linux_amd64.zip
unzip packer_${PACKER_VER}_linux_amd64.zip

#######################
# Install Terraform 
#######################

TERRAFORM_VER="0.12.12"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip
unzip terraform_${TERRAFORM_VER}_linux_amd64.zip

#######################
# Install Kops 
#######################

KOPS_VER="1.11.1"
wget https://github.com/kubernetes/kops/releases/download/${KOPS_VER}/kops-linux-amd64
chmod +x kops-linux-amd64

sudo -s -- <<EOF
		
	mv packer /usr/local/bin
	rm packer_${PACKER_VER}_linux_amd64.zip

	mv terraform /usr/local/bin
	rm terraform_${TERRAFORM_VER}_linux_amd64.zip

	mv kops-linux-amd64 /usr/local/bin/kops

	export DEBIAN_FRONTEND=noninteractive
	apt-add-repository --yes --update ppa:ansible/ansible
	apt-get update
	apt-get install -y ansible

	apt-get update
	apt-get install -y apt-transport-https
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 2> /dev/null
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
	apt-get update
	apt-cache policy docker-ce
	apt-get install -y docker-ce

	curl -L https://github.com/docker/compose/releases/download/1.25.0-rc2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose

	apt-get update
	apt-get install -y jq

	curl -o /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest
	chmod +x /usr/local/bin/ecs-cli

	ufw allow ssh
	echo "y" | ufw enable

EOF
