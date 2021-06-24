#!/bin/bash

# Author: Juliana Gonçalves da Costa Soares <juliana.goncosta@gmail.com>
# Author URI: https://github.com/jucostag

SCRIPT_NAME=$(basename $0)

TMP_DIR=~/tmp

AWS_S3_ACCESS_KEY_ID=
AWS_S3_ACCESS_SECRET_KEY=
AWS_S3_DEFAULT_REGION=
AWS_S3_BUCKET=

DB_TABLES_PREFIX=

CURRENT_YEAR=$(date -d "$D" '+%Y')
CURRENT_MONTH=$(date -d "$D" '+%m')
CURRENT_DAY=$(date -d "$D" '+%d')

usage(){
	# Help
	echo "
	Execute:
	$SCRIPT_NAME [S3 directory]
	Options: 'example-1', 'example-2', 'example-3'
	Example:
	$SCRIPT_NAME example-1 my-user my-pass 0.0.0.0 my-name
	"
	exitfunc "[ ERROR ] - Invalid Argument"
}

getTableNames(){
    echo "retrieving list of table names from $S3_DIR's $DB_NAME..."
    mysql -u$DB_USER -p$DB_PASS -h$DB_HOST --verbose -e "SELECT table_name FROM information_schema.tables WHERE table_schema = '$DB_NAME'" > ~/tmp/.tables
    sed -i "/$DB_TABLES_PREFIX/!d" $TMP_DIR/.tables
}

getDataByTable(){
    
    getTableNames

    while read table
        do echo "copying ${table} from $S3_DIR's $DB_NAME..."
        table=${table/$'\r'/}
        result_file="${table}.sql"
        mysqldump -u$DB_USER -p$DB_PASS -h$DB_HOST --skip-lock-tables --no-tablespaces $DB_NAME $table > $TMP_DIR/$result_file
        wait
    done < $TMP_DIR/.tables
    wait

    echo "removing temporary file .tables..."
    rm -rf $TMP_DIR/.tables
}

copyToS3(){
    aws configure set aws_access_key_id $AWS_S3_ACCESS_KEY_ID
    aws configure set aws_secret_access_key $AWS_S3_ACCESS_SECRET_KEY
    aws configure set default.region $AWS_S3_DEFAULT_REGION

    for SQL_FILE in $TMP_DIR/*;
        do aws s3 cp $SQL_FILE s3://$AWS_S3_BUCKET/$S3_DIR/$CURRENT_YEAR/$CURRENT_DAY-$CURRENT_MONTH/;
    done;
}

cleanTempDir() {
    echo "removing all temporary files..."
    rm -rf $TMP_DIR/*
}

executeBackup(){
	echo "starting backup..."

    getDataByTable

    copyToS3

    cleanTempDir
}


# Validating argument S3_DIR
[[ $# -ne 1 ]] && usage
S3_DIR=$1
DB_USER=$2
DB_PASS=$3
DB_HOST=$4
DB_NAME=$5

[ $S3_DIR ] || usage
executeBackup $S3_DIR