#!/bin/bash
envWorkspace="/home/ubuntu/devops/mongo_backup"
source_env=$1
source_db=$2
project_name=$3
backup_date=$4

untar(){
	mkdir /tmp/$project_name
	tar -xvzf /tmp/${source_db}mongodump-$backup_date-* -C /tmp/
	find /tmp/${source_db}mongodump/ -type f -name "$project_name*" -exec cp {} /tmp/$project_name/ \;
	tar -zcvf /tmp/${source_env}_${project_name}.tar.gz /tmp/$project_name/
}
upload_to_s3(){
	aws s3 cp /tmp/${source_env}_${project_name}.tar.gz s3://kgm-mongo-backup/
}
if [ $source_env = "prod" ] ; then
	
	echo "Copying backup from ${source_env} to Jenkins machine"
	scp jenkins@IP:$envWorkspace/${source_db}mongodump-$backup_date-* /tmp/

elif [ $source_env = "sit" ] ; then	
	
	echo "Copying backup from ${source_env} to Jenkins machine"
        scp jenkins@IP:$envWorkspace/${source_db}mongodump-$backup_date-* /tmp/

elif [ $source_env = "dev" ] ; then 

        echo "Copying backup from ${source_env} to Jenkins machine"
        scp jenkins@IP:$envWorkspace/${source_db}mongodump-$backup_date-* /tmp/

elif [ $source_env = "beta" ] ; then

        echo "Copying backup from ${source_env} to Jenkins machine"
        scp jenkins@IP:$envWorkspace/${source_db}mongodump-$backup_date-* /tmp/

fi
clean_up(){
	rm -rf /tmp/${source_db}mongodump*
        rm -rf /tmp/$project_name*
	rm -rf /tmp/${source_env}_*
}
untar
upload_to_s3
clean_up
echo "Use below URL to download the project dump"
echo "https://s3.ap-south-1.amazonaws.com/kgm-mongo-backup/${source_env}_${project_name}.tar.gz"
