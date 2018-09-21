#!/bin/bash

# Some regional information
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*$:\\1:'`"

# Check if mandatory variables are set
for var in MYSQL_HOST MYSQL_PWD MYSQL_USER DB_DATABASE S3_BUCKET S3_PATH; do
	if ! [ -n "${!var}" ] ; then
		echo "Mandatory variable $var is not set"
		exit 1
	fi
done

set -u

if [[ $LOGLEVEL == "DEBUG" ]]; then
	echo "aws sts get-caller-identity"
	aws sts get-caller-identity
	[ $? -eq 0 ] || exit $?
fi

if [[ $REPLACEDATE == "YES" ]]; then
	DATE=`date +%Y-%m-%d`
	S3_PATH = $(echo $S3_PATH | sed "s/%date/$DATE/")
	echo "date replaced %date in S3_PATH. New value: $S3_PATH"
fi

# Iterate all env settings
for env_key in $(compgen -e); do
	# If _value_ matches SSM_SECRET, use SSM parameter store
	if [[ ${!env_key} == SSM_SECRET_* ]]; then
		if [[ $LOGLEVEL == "DEBUG" ]]; then
			echo "Mapping $env_key to SSM parameter ${!env_key:11}";
		fi

		# Fetch the parameter from SSM parameter store
		env_value=$(aws ssm get-parameters --names ${!env_key:11} --with-decryption --region $EC2_REGION --output text --query Parameters[0].Value)
		[ $? -eq 0 ] || exit $?

		export ${env_key}="${env_value}"
		if [[ $LOGLEVEL == "DEBUG" ]]; then
			echo "Retrieved secret $env_value from SSM parameter store"
		fi
	fi
done

echo "Retrieve list of table backups from S3"
tables=$(aws s3 ls s3://$S3_BUCKET/$S3_PATH/ | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//' | sed '/^\s*$/d'; exit ${PIPESTATUS[0]})
[ $? -eq 0 ] || exit $?

echo "restore tables from s3"
for table in $tables
do
	echo "table: $table"
	aws s3 cp s3://$S3_BUCKET/$S3_PATH/$table - | gunzip | mysql -u $MYSQL_USER $DB_DATABASE
done
echo "restore complete"
