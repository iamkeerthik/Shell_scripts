#!/bin/bash
date1=$(date -d "2 days ago" +%Y-%m-%d)
# date2=$(date -d "1 day ago" +%Y-%m-%d)
container_name_pattern="ubuntu-*"
zip_file="/home/ec2-user/script/logs/FRPSClient-$date1.tar.gz"
LOGS_PATH=/home/ec2-user/script/logs
bucket=terrafrm-state-files/logs/

# Pull log file from container
if ! docker cp -a $(docker ps -aqf "name=$container_name_pattern"):/home/FRPSClient-$date1.log $LOGS_PATH/; then
    echo "Failed to copy log file from container"
    exit 1    
fi

# Compress log file into ZIP file
if ! tar -zcvf $zip_file $LOGS_PATH/FRPSClient-$date1.log; then
    echo "Failed to zip log file"
    rm $zip_file
    exit 1
else
    rm $LOGS_PATH/FRPSClient-$date1.log
fi

# Upload ZIP file to S3
if ! aws s3 cp $zip_file s3://$bucket ; then
    echo "Failed to upload ZIP file to S3"
    exit 1
else
    rm  $zip_file
    echo "Deleting file from container"
    docker exec $(docker ps -aqf "name=$container_name_pattern") rm -f /home/FRPSClient-$date1.log
fi

