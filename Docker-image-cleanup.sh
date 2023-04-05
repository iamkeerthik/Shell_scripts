#!/bin/bash

# Set the number of days to keep images
DAYS_TO_KEEP=7

# Remove dangling images
echo "Removing dangling images..."
docker image prune -f

# Remove old images
echo "Removing old images..."
docker images --format "{{.ID}} {{.Repository}} {{.Tag}} {{.CreatedAt}}" | grep -v '<none>' | while read line
do
    IMAGE_ID=$(echo $line | awk '{print $1}')
    REPOSITORY=$(echo $line | awk '{print $2}')
    TAG=$(echo $line | awk '{print $3}')
    CREATED_AT=$(echo $line | awk '{print $4}')
    CREATED_DATE=$(date -d $CREATED_AT +%s)
    NOW=$(date +%s)
    DAYS=$(( (NOW - CREATED_DATE) / 86400 ))
    if [[ $DAYS -gt $DAYS_TO_KEEP ]]; then
        echo "Removing old image: $REPOSITORY:$TAG (created $DAYS days ago)..."
        docker rmi $IMAGE_ID
    fi
done

echo "Cleanup complete."
