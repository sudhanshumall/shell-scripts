#!/bin/bash
# Stop on any errors
#set -e

USERNAME=$1

#PATH_OF_MACHINES=/var/lib/jenkins/workspace/UserCreation/

if [ -z "$USERNAME" ]; then
        echo "Username required"
        exit 1;
fi

for machines in `aws ec2 describe-instances --query 'Reservations[*].Instances[*].[PrivateIpAddress]' | grep -Ev '(\[|\])' | awk 'BEGIN {FS="\""} {print $2}'`
        do

                ansible $machines -m shell -a "sudo userdel -r $USERNAME"
		ansible $machines -m shell -a "sudo groupdel $USERNAME"
        done

