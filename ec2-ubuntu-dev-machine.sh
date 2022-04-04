#!/bin/bash

# Usage: ./deploy-ec2-ubuntu-dev-machine <Build Option>

function error_and_die() {
  echo -e "[ERROR] ${1}" >&2;
  exit 1;
}

function myerror() {
	echo -e "[ERROR] ${1}" >&2;
}

declare deregister_image;
declare build_option="${1}";



# Get Public IP
my_ip="$(curl -s https://api.ipify.org || echo "Failed")";
[ "${my_ip}" == "Failed" ] \
  && error_and_die "Failed to retrieve your IP from api.ipify.org";

# Cidr block
my_cidr="${my_ip}/32";

# ...
ami_file="my_ami";
snapshot_file="my_snapshot";

#########################################################################################
#																						                                            #
#																						                                            #
# 	DO NOT MAKE ANY CHANGES ABOVE..														                          #
#																						                                            #
#																						                                            #
#########################################################################################

# ...
aws_default_profile="";

# ...
network_acl_id="";
grp_id="";
rule_number=120;
port_range=22;

# ...
project_dir="./../../../../../../../aws-accounts/dev-jcs/projects/ec2-ubuntu-dev-machine"

# ...
artifacts_file="ec2-ubuntu-dev-machine_build_artifacts";
packer_bld_file="ec2-ubuntu-dev-machine";

#########################################################################################
#																						                                            #
#																						                                            #
# 	DO NOT MAKE ANY CHANGES BELOW..														                          #
#																						                                            #
#																						                                            #
#########################################################################################

# ...
my_ami="$(cat my_ami.txt)";
my_snapshot="$(cat my_snapshot.txt)";

export AWS_DEFAULT_PROFILE=${aws_default_profile};

# ...
if [[ "${build_option}" == "" ]]; then
	echo -en "Please enter a build option.  Thank you.  i.e [ build ]\n";
fi

if [[ "${build_option}" == "build" ]]; then
	
# ... Deletes the existing network acl entry
	echo -en "Deleting existing network acl entry: ${network_acl_id} ...";
	aws ec2 delete-network-acl-entry \
		--network-acl-id ${network_acl_id} \
		--ingress --rule-number ${rule_number} \
		&& echo -e "Successfull" \
		|| echo -e "Failed\nInformation Only!..\nWill now create  network entry in ${network_acl_id}";	

# ... Creates a network acl entry with my Public IP
	echo -en "Creating new network acl entry: ${network_acl_id} ... ";
	aws ec2 create-network-acl-entry \
		--network-acl-id ${network_acl_id} \
		--ingress --rule-number ${rule_number} \
		--protocol tcp \
		--port-range From=${port_range},To=${port_range} \
		--cidr-block ${my_cidr} \
		--rule-action allow \
		&& echo -e "Successfull" \
		|| echo -e "Failed";

	echo -en "Deregistering ami: ${my_ami}... ";
	deregister_image="$(aws ec2 deregister-image \
		--image-id ${my_ami} \
		|| echo "Failed")";

	if [[ "${deregister_image}" == "Failed" ]]; then
		echo -en "Failed\nPlease remember you might need to remove snap-shot from console.  Thank you!..\n";
		else
			echo -en "Successfull\nDeleting snapshot ${my_snapshot}...";
				aws ec2 delete-snapshot \
				--snapshot-id ${my_snapshot} \
				&& echo -e "Successfull" \
				|| echo -e "Failed"; # Non-fatal..	
	fi

	echo -en "Building new ami: ${packer_bld_file}...\n"
	packer build -machine-readable ${packer_bld_file}.json | tee ${artifacts_file}.txt \
		&& echo -e "Successfull" \
		|| echo -e "Failed";

	echo -en "Writing image-id: ${my_ami} to file...";
	sed -n 's/.*AMI: //p' ${artifacts_file}.txt > ${ami_file}.txt \
		&& echo -e "Done" || echo -e "Failed\nIf not found the file will be created!..";

	echo -en "Writing snapshot-id: ${my_snapshot} to file...";
	sed -n 's/.*Tagging snapshot: //p' ${artifacts_file}.txt > ${snapshot_file}.txt \
			&& echo -e "Done" || echo -e "Failed\nIf not found the file will be created!..";

fi
# ... 
if [[ "${build_option}" == "delete" ]]; then	
	echo -en "Deregistering ami image-id: ${my_ami}... ";
	deregister_image="$(aws ec2 deregister-image \
		--image-id ${my_ami} \
		|| echo "Failed")";

	if [[ "${deregister_image}" == "Failed" ]]; then
		echo -en "Failed\nPlease remember you might need to remove snap-shot from console.  Thank you!..\n";
		else
			echo -en "Successfull\nDeleting snapshot-id: ${my_snapshot}...";
				aws ec2 delete-snapshot \
				--snapshot-id ${my_snapshot} \
				&& echo -e "Successfull" \
				|| echo -e "Failed"; # Non-fatal..	
	fi

fi
# ...
if [[ "${build_option}" == "apply" ]]; then
	echo -en "This is going to apply the terraform script\n";
	cd ${project_dir};
	terraform ${build_option} -auto-approve;

fi

if [[ "${build_option}" == "destroy" ]]; then
	echo -en "This is going to destroy the ec2 Instance created by the terraform script\n";
	cd ${project_dir};
	terraform ${build_option} -auto-approve;
	echo -en "Deregistering ami image-id: ${my_ami}... ";
	deregister_image="$(aws ec2 deregister-image \
		--image-id ${my_ami} \
		|| echo "Failed")";

	if [[ "${deregister_image}" == "Failed" ]]; then
		echo -en "Failed\nPlease remember to remove snap-shot from console.  Thank you!..\n";
		else
			echo -en "Successfull\nDeleting snapshot-id: ${my_snapshot}...";
				aws ec2 delete-snapshot \
				--snapshot-id $my_snapshot \
				&& echo -e "Successfull" \
				|| echo -e "Failed"; # Non-fatal..	
	fi

fi

# No errors
exit 0;
