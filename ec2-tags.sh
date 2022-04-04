#!/bin/bash

ec2_ubuntu_dev_machine=i-1234567891

set -e

export AWS_DEFAULT_PROFILE=dev-jcs

aws ec2 create-tags \
    --resources $ec2_ubuntu_dev_machine \
    --tags 	Key=Name,Value=jagho-web-site \
    		Key=ProvisionedBy,Value="Yomi Ogunyinka" \
    		Key=Role,Value="Company Web Site" \
    		Key=Environment,Value=demo \
    		Key=webapp,Value=Apache
