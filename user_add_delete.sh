###### This is the script to add and delete user on the linux machines ######

###### This script would be really helpful if you run this from you Ansible control Machine #####
###### If running this script from Ansible Control Machine, then changes will be as mentioned below #####
######   ansible $machines -m shell -a "YOUR COMMAND"   #############

#!/bin/bash

USERNAME=$1
ADD_DELETE=$2

ADD_USER() {
	for machines in `cat filename.txt`  ## Here filename.txt will contain the linux machine IP's
		do
			sudo groupadd $USERNAME
			STATUS=`echo $?`
			if [ $STATUS -eq 0 ]; then
				sudo useradd -s /bin/bash -m -d /home/$USERNAME  -g $USERNAME $USERNAME
				sudo mkdir -p /home/$USERNAME/.ssh
				sudo chown $USERNAME:$USERNAME /home/$USERNAME/.ssh
				sudo touch /home/$USERNAME/.ssh/authorized_keys
				sudo chmod 777 /home/$USERNAME/.ssh
				scp public_key_file.txt username_with_which_you_will_ssh@$machine:/home/$USERNAME/.ssh/authorized_keys
				sudo chmod 700 /home/$USERNAME/.ssh
				sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
				sudo chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys
				sudo usermod -a -G ubuntu $USERNAME
			else echo "User Already available on $machines"
			fi
		done
		}

DELETE_USER() {

	for machine in `cat filename.txt`  ## Here file will contain the linux machine IP's
		do
			sudo userdel -r $USERNAME
		done
}

case $ADD_DELETE in 
	add) ADD_USER ;;
	delete) DELETE_USER ;;
	*)     echo "ERROR Occured : This script accepts 3 arguments as below : \n
			1st argument : username \n
			2nd argument : add or delete (add will add the user and delete will delete the user) \n
			3rd argument : you public ssh-keygen file" ;;
	esac

