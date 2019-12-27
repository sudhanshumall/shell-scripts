#!/bin/bash
recipient_address="mall.sudhanshu90@gmail.com"
#cd /home/ubuntu/devops
ENV=$1
today=`date +"%d-%m-%Y-%H%M"`
echo $today
year=`date +%Y`
month=`date +%m | sed 's/^0//g'`
sudo rm -rf $1-mysql-backup
if [ -z "$1"  ]; then
        echo "Please provide client name as an argument for which dump has to be taken"
        exit 1
fi

aws s3 ls s3://${ENV}-mysql-backup 2>&1 | grep 'NoSuchBucket'

if [ $? -eq 0 ] ; then
        echo "Bucket doesn't exist and hence creating the bucket for new client ${ENV} before taking mysql dump"
        aws s3 mb s3://${ENV}-mysql-backup
else
        echo "Bucket alreay present and going to take mysql dump for ${ENV}"
fi

mysql -uuser -ppassword -e "show databases;" | grep -vE "(Database|information_schema|mysql|performance_schema|sys|temp)" > db_list.txt

echo "==========Printing DB list for which mysql dump has to be taken==========="


cat db_list.txt
sudo mkdir -p $1-mysql-backup
sudo chown -R jenkins:jenkins $1-mysql-backup   # As I am running from Jenkins user

for db in `cat db_list.txt` ; do echo "taking dump for $db" && mysqldump -uuser -ppassword --routines $db > $1-mysql-backup/$db-$today.sql;done

status=`echo $?`
echo $status
if [ $status -eq 0 ]; then
        sudo tar -zcvf $1-mysql-backup-$today.tar.gz $1-mysql-backup
        sudo cp $1-mysql-backup-*.tar.gz /home/ubuntu/devops/mysql_backup
        sudo cp $1-mysql-backup-*.tar.gz /home/ubuntu/devops/aws_mysql_backup
        aws s3 cp /home/ubuntu/devops/aws_mysql_backup/ s3://${ENV}-mysql-backup/ --recursive
        sudo rm -fv /home/ubuntu/devops/aws_mysql_backup/*
else
        echo "mysql backup failed on $ENV" | mail -s "mysql backup failed on $ENV"  $recipient_address
fi

