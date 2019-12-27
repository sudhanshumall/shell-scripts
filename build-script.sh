#!/bin/bash

#### This is build script
for var in "$@"
do
cd /var/lib/jenkins/workspace && rm -rf $var && git clone ssh://git@GIT_IP/KGM_Dev/$var.git && cd /var/lib/jenkins/workspace/$var && git checkout $branch_name && git pull

done
