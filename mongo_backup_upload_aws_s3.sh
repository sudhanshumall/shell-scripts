#!/bin/bash
recipient_address="mall.sudhanshu90@gmail.com"
#cd /home/ubuntu/devops
today=`date +"%d-%m-%Y-%H%M"`
echo $today
ENV=$1
year=`date +%Y`
month=`date +%m | sed 's/^0//g'`
if [ ! -d /home/ubuntu/devops/mongo_backup ]; then
        sudo mkdir -p /home/ubuntu/devops/mongo_backup
else
exit 
fi

if [ -z "$1"  ]; then
        echo "Please provide ENV as an argument for which dump has to be taken"
        exit 1
fi

## Checking bucket exists on S3 or not
aws s3 ls s3://${ENV}-mongo-backup 2>&1 | grep 'NoSuchBucket'

if [ $? -eq 0 ] ; then
        echo "Bucket doesn't exist and hence creating the bucket for ${ENV} before taking mongo dump"
        aws s3 mb s3://${ENV}-mongo-backup
else
        echo "Bucket alreay present and going to take mongo dump for ${ENV}"
fi


echo "Taking mongo backup on `hostname`"
sudo mongodump --username mongoUsername --password mongoPassword  -d mongoDB -o mongoDumpFile
sleep 10

status=`echo $?`
echo $status
if [ $status -eq 0 ]; then
                sudo tar -zcvf mongoDumpFile-"$today.tar.gz" mongoDumpFile
                sudo rm -rf mongoDumpFile
                sudo cp mongoDumpFile-* /home/ubuntu/devops/mongo_backup/
		sudo cp mongoDumpFile-* /home/ubuntu/devops/aws_mongo_backup/
		aws s3 cp /home/ubuntu/devops/aws_mongo_backup/ s3://${ENV}-mongo-backup/ --recursive
		sudo rm -rf /home/ubuntu/devops/aws_mongo_backup/*
        else
                echo "mongo backup failed on `hostname`" | mail -s "mongo backup failed on `hostname`"  $recipient_address
fi

