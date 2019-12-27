#!/bin/bash
#### this script is written in order to update the code from git based on the repositories and it will create tag also 
#### In case if you want to give manual tag, then you can use Jenkins paramter and can create a variable called manual_tag
#### So, in this script if manual_tag is defined while building the job, then it will download manual defined tag else it will download from the mentioned branch and will create new tag respective to that branch
#### variables tag_name and branch_name has been defined in jenkins pipeline/job

WORK_SPACE=""  		        	### define your workspace path where you want to maintain your codebase on machine
SSH_GIT="ssh://git@IP/KGM_Dev"         	### defined your git url 
if [ ! -d $WORK_SPACE ] ; then
        mkdir -p $WORK_SPACE
fi
for app_name in "$@"
do
	if [ ! -z $manual_tag ]         #### variable manual tag will be defined in Jenkins job and while building you can provide the tag
	then
	        echo "manual tag defined, hence downling the same : $manual_tag"
        	curl -L $SSH_GIT/$app_name/$manual_tag.tar.gz | tar xz
		rm -rf $app_name
		mv $app_name-$maual_tag $app_name
	else
        	cd $WORK_SPACE && rm -rf $app_name && git clone $SSH_GIT/$app_name.git && cd $WORK_SPACE/$app_name && git checkout $branch_name && git stash && git pull
        	git tag -l > $WORK_SPACE/$app_name_git_tag.txt
        	if [ -s $WORK_SPACE/$app_name_git_tag.txt ]
                then
                       	echo " File not empty"
	                current_tag=`git tag -l | awk 'BEGIN {FS="-"}{print $NF}' | sort -nr  | head -1`
                        echo "current tag: $tag_name-"$current_tag
                        new_tag=`expr $current_tag + 1`
        	        echo "New created tag is : $new_tag"
               	        release_tag="$tag_name-"$new_tag
                       	git tag -a "$release_tag" $branch_name -m 'tagging from branch '$branch_name
                       	git push $SSH_GIT/$app_name.git tag $release_tag $branch_name
        	else
                        echo " File empty and hence creating new tag"
                        git tag -a "$tag_name-1" $branch_name -m 'First Tag created '$branch_name
                git push $SSH_GIT/$app_name.git tag "$tag_name-1" $branch_name
        	fi
	fi
done
