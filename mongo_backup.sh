#!/bin/bash
recipient_address="mall.sudhanshu90@gmail.com"
#cd /home/ubuntu/devops
today=`date +"%d-%m-%Y-%H%M"`
echo $today
year=`date +%Y`
month=`date +%m | sed 's/^0//g'`
if [ ! -d /home/ubuntu/devops/mongo_backup ]; then
        sudo mkdir -p /home/ubuntu/devops/mongo_backup
else
exit 
fi
echo "Taking mongo backup on `hostname`"
sudo mongodump --username mongoUserName --password mongoPassword  -d mongoDB -o mongoDumpFile
sleep 10

status=`echo $?`
echo $status
if [ $status -eq 0 ]; then
                sudo tar -zcvf mongoDumpFile-"$today.tar.gz" mongoDumpFile
                sudo rm -rf mongoDumpFile
                sudo mv mongoDumpFile-* /home/ubuntu/devops/mongo_backup/

		#  You can upload the dump file to S3 as well, using aws s3 cp command 

        else
                echo "mongo backup failed on `hostname`" | mail -s "mongo backup failed on `hostname`"  $recipient_address
fi

