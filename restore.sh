#!/bin/bash

# Set these
#export MYSQL_HOST=
#export MYSQL_PWD=

#export MYSQL_USER=

#export AWS_PROFILE=

#DB_DATABASE=

#S3_BUCKET=
#S3_PATH=

set -u

echo "read tables from s3"
tables=$(aws s3 ls s3://$S3_BUCKET/$S3_PATH/ | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//' | sed '/^\s*$/d')

echo "restore tables from s3"
for table in $tables
do
	echo "table: $table"
	aws s3 cp s3://$S3_BUCKET/$S3_PATH/$table - | gunzip | mysql -u $MYSQL_USER $DB_DATABASE
	exit
done
