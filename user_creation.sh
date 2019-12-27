#!/bin/bash
# Stop on any errors
#set -e

USERNAME=$1

#PATH_OF_MACHINES=/var/lib/jenkins/workspace/UserCreation/

if [ -z "$USERNAME" ]; then
        echo "Username required"
        exit 1;
fi

#for machines in `cat $PATH_OF_MACHINES/ec2-machine-list.txt`
for machines in `aws ec2 describe-instances --query 'Reservations[*].Instances[*].[PrivateIpAddress]' | grep -Ev '(\[|\])' | awk 'BEGIN {FS="\""} {print $2}'`
        do
                ansible $machines -m shell -a "sudo groupadd $USERNAME"
                status=`echo $?`
                echo $status
                        if [ $status -eq 0 ]; then
                                ansible $machines -m shell -a "sudo useradd -s /bin/bash -m -d /home/$USERNAME  -g $USERNAME $USERNAME"
                                ansible $machines -m shell -a "sudo mkdir -p /home/$USERNAME/.ssh"
                                ansible $machines -m shell -a "sudo chown $USERNAME:$USERNAME /home/$USERNAME/.ssh"
				ansible $machines -m shell -a "sudo chmod 777 /home/$USERNAME/.ssh"
                                ansible $machines -m copy -a "src=/var/lib/jenkins/workspace/${JOB_NAME}/users_public_keys/$USERNAME.pub dest=/home/$USERNAME/.ssh/authorized_keys"
                                ansible $machines -m shell -a "sudo chmod 700 /home/$USERNAME/.ssh"
                                ansible $machines -m shell -a "sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys"
                                ansible $machines -m shell -a "sudo chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys"
				ansible $machines -m shell -a "sudo usermod -a -G ubuntu $USERNAME"
			else echo "User Already available on $machines"
                        fi
        done

