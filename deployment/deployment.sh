#!/bin/bash

LOG_FILE="/home/ubuntu/deployment/deploy.log"
IMAGE_NAME="omb9/bhavsar-ceg3120"
TAG="latest"

echo "$(date) - Starting deployment" >> $LOG_FILE

# Stop and remove existing containers
docker stop $(docker ps -q --filter ancestor=${IMAGE_NAME}:${TAG}) >> $LOG_FILE 2>&1
docker rm $(docker ps -a -q --filter ancestor=${IMAGE_NAME}:${TAG} --filter status=exited) >> $LOG_FILE 2>&1

# Pull the latest image
docker pull ${IMAGE_NAME}:${TAG} >> $LOG_FILE 2>&1

# Run a new container
docker run -d -p 80:80 ${IMAGE_NAME}:${TAG} >> $LOG_FILE 2>&1

echo "$(date) - Deployment finished" >> $LOG_FILE