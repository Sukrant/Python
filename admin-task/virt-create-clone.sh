#!/bin/bash

usage(){
	echo "
	
	./create-clone <Virtual-Machine-Name> <template-name>
	
	"
}

clone_creation(){
virt-clone -o $template_name -n $vm_name -f /data/vm_images/$vm_name/system.img

		if [ $? == 0 ]; then
			echo "Virtual Machine $vm_name created"
			virsh dominfo $vm_name
		else
			echo "There are some issues while cloning  Virtual machine, please do it manually"
		fi
}

vm_checking(){
# Checking Desired Virtual Machine name is exit or not
		if [ ! -z `virsh list --all --name|grep -x $vm_name` ]; then
			echo "Virtual machine name is already taken. Exiting"
			echo "`virsh list --all |grep $vm_name`"
			exit 1
		fi
	}

vm_dir_checking(){
		if [ -d "/data/vm_images/$vm_name" ]; then
			echo " Virtual machine directory already exist, please taken care of. Exiting "
			exit 1
		else
			mkdir /data/vm_images/$vm_name
		fi
	}


if [ $# -lt 2 ] || [ $# -gt 2 ] ; then
	usage

##Clone required yes or no
read -p "Still need to create clone :" clone

#Template Virtual Machine Names
template=`virsh list --all --name| grep template| nl`

#Virtual Machine excluding templates
vms=`virsh list --all --name | egrep -v "template|^$"`

# clone decision 
if [ $clone == y ] || [ $clone == Y ]  || [ $clone == Yes ] || [ $clone == yes ] || [ $clone == YES ]; then
	read -p "Which machine clone you like to build , Below we have :

$template

	:-   Put your number

		:" template_number

#check template number
template_list=`virsh list --all --name| grep template| nl| cut -f 1`
for i in $template_list
do
	if [ $template_number -eq $i ];then
		wrong_template=1
		break
	fi
done

if [[ "$wrong_template" -ne  1 ]]; then
	echo "Provided template number is not correct , Exit"
	exit 1
fi


#Required Virtual machine Name
	read -p "Only new name would be acceptable,Below are existing one :

$vms

	:-   What would be Virtual Machine Name
		
		:" vm_name
		vm_checking
		vm_dir_checking
		# Template Name
		template_name=`virsh list --all --name| grep template| nl| grep "^[[:space:]]\+$template_number"|cut -f 2`
		clone_creation

else 
	echo " Wrong input ..Exit... "
fi

elif [ $# -eq 2 ];then
	template_name=$2
	vm_name=$1
	vm_checking
	vm_dir_checking
	clone_creation
fi