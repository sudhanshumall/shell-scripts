#!/bin/bash

# You need to create one IAM user which has access to stop and start RDS instance and using aws configure, you can set it.

# This script is helpful if you are using RDS for your Dev and QA environment and you don't want to run your RDS 24*7

# This script takes 2 parameters 1st - RDS DB Name and 2nd - start or stop action

set -u
AWS_CLI="aws rds"
DATE=`date +%Y-%m-%d`
LOGDIR="/var/log/rds"
LOG_START_RDS=$LOGDIR/startlog.$DATE
LOG_STOP_RDS=$LOGDIR/stoplog.$DATE
RDS_DB_NAME=$1

if [ ! -d $LOGDIR ] ; then
	sudo mkdir -p $LOGDIR
	sudo chmod 777 $LOGDIR
fi

start_rds(){
	echo "starting RDS DB : $RDS_DB_NAME" | tee -a $LOG_START_RDS
	$AWS_CLI start-db-instance --db-instance-identifier $RDS_DB_NAME | tee -a $LOG_START_RDS
}

stop_rds(){
	echo "stopping RDS DB : $RDS_DB_NAME" | tee -a $LOG_STOP_RDS
        $AWS_CLI stop-db-instance --db-instance-identifier $RDS_DB_NAME | tee -a $LOG_STOP_RDS
}

OPTION=$2

case $OPTION in 
	start) start_rds ;;
	stop) stop_rds ;;
	*) 	echo "ERROR Occured : Valid options are start/stop" ;;
esac

