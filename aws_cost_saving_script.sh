#!/bin/bash
set -u
AWS_CLI='/usr/local/bin/aws ec2'
DATE=`date +%Y-%m-%d`
LOGDIR="/var/log/nightsleep"
LOG_START_INST=$LOGDIR/startlog.$DATE
LOG_STOP_INST=$LOGDIR/stoplog.$DATE



if [ ! -d $LOGDIR ] ; then
	mkdir -p $LOGDIR
	chmod 700 $LOGDIR
fi


COLLECT_NIGHT_SLEEP_INSTANCES () {
	$AWS_CLI describe-tags --filters "Name=resource-type,Values=instance" "Name=key,Values=NightSleep" | grep ResourceId | awk '{split($0,a,"\"")} {print a[4]}'
	#$AWS_CLI describe-tags --filters "Name=resource-type,Values=instance" "Name=key,Values=NightSleep" | grep ResourceId | awk '{print $NF}'| cut -d '"' -f2
}

 INSTANCE_START () {
	INST_NIGHT_SLEEP=`COLLECT_NIGHT_SLEEP_INSTANCES`

	for INSTANCE_ID in $INST_NIGHT_SLEEP; do
		echo "##### Working on Instance startup :  $INSTANCE_ID #### " | tee -a $LOG_START_INST
		$AWS_CLI start-instances --instance-id $INSTANCE_ID | tee -a $LOG_START_INST
	done
}
 INSTANCE_STOP () {
	INST_NIGHT_SLEEP=`COLLECT_NIGHT_SLEEP_INSTANCES`
	for INSTANCE_ID in $INST_NIGHT_SLEEP; do
		echo "##### Working on Instance stop  : $INSTANCE_ID #### " | tee -a $LOG_STOP_INST
		$AWS_CLI stop-instances --instance-id $INSTANCE_ID | tee -a $LOG_STOP_INST
	done
}
 INSTANCE_STATUS () {
	INST_NIGHT_SLEEP=`COLLECT_NIGHT_SLEEP_INSTANCES`
	for INSTANCE_ID in $INST_NIGHT_SLEEP; do
	INSTANCE_STATE=`aws ec2 describe-instances --instance-id $INSTANCE_ID --output text | grep -w STATE | awk '{print $NF}'`
	echo "Instance $INSTANCE_ID is under Night Sleep and its current state is : $INSTANCE_STATE"
	done
}

OPTION=$1
case $OPTION in 
	start)  INSTANCE_START ;;
	stop)   INSTANCE_STOP ;;
	status) INSTANCE_STATUS ;;
	*)      echo "Error occoured : vaild options are start/stop/status" ;;
esac
exit 0
