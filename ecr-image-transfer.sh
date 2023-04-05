#!/bin/bash

# Set the source ECR repository details
SOURCE_PROFILE=<source_aws_profile>
SOURCE_REGION=<source_region>
SOURCE_ACCOUNT_ID=<source_account_id>
SOURCE_REPO_NAME=<source_repo_name>

# Set the destination ECR repository details
DEST_PROFILE=<destination_aws_profile>
DEST_REGION=<destination_region>
DEST_ACCOUNT_ID=<destination_account_id>
DEST_REPO_NAME=<destination_repo_name>

# Set the image tags for the source and destination repositories
SOURCE_TAGS=(
  "source-image-1:latest"
  "source-image-2:latest"
  "source-image-3:latest"
)

DEST_TAGS=(
  "destination-image-1:latest"
  "destination-image-2:latest"
  "destination-image-3:latest"
)

# Authenticate with the source ECR repository
$(aws ecr get-login --no-include-email --region $SOURCE_REGION --profile $SOURCE_PROFILE)

# Authenticate with the destination ECR repository
$(aws ecr get-login --no-include-email --region $DEST_REGION --profile $DEST_PROFILE)

# Loop over the image tags and pull, tag, and push each image
for i in "${!SOURCE_TAGS[@]}"; do
  SOURCE_TAG="${SOURCE_TAGS[$i]}"
  DEST_TAG="${DEST_TAGS[$i]}"
  SOURCE_IMAGE=$SOURCE_ACCOUNT_ID.dkr.ecr.$SOURCE_REGION.amazonaws.com/$SOURCE_REPO_NAME:$SOURCE_TAG
  DEST_IMAGE=$DEST_ACCOUNT_ID.dkr.ecr.$DEST_REGION.amazonaws.com/$DEST_REPO_NAME:$DEST_TAG

  # Pull the Docker image from the source ECR repository
  docker pull $SOURCE_IMAGE

  # Tag the Docker image with the destination ECR repository details
  docker tag $SOURCE_IMAGE $DEST_IMAGE

  # Push the Docker image to the destination ECR repository
  docker push $DEST_IMAGE

  # Remove the locally cached Docker image
  docker rmi $DEST_IMAGE
done
