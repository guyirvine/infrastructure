#!/bin/bash

REGISTRY="localhost:5100"
SERVICE="$JOB_NAME"
FINAL_SERVICE="$REGISTRY/$SERVICE"
SERVICE_PORT=9000

echo "** Build Docker Image: $SERVICE $WORKSPACE"
sudo docker build -t "$SERVICE" "$WORKSPACE" || exit 1

IMAGE_ID=$(sudo docker images | grep "$SERVICE" | grep -v "$REGISTRY" | grep latest | awk '{print $3}')
if [ -z "$IMAGE_ID" ]; then echo "** No image id"; exit 2; fi
echo "** New image id: $IMAGE_ID"

CONTAINER_PORT=$(sudo docker inspect --format '{{ .Config.ExposedPorts }}' "$IMAGE_ID" | awk '{match($1,"[0-9]+",a)}END{print a[0]}')
if [ -z "$CONTAINER_PORT" ]; then echo "** No container port"; exit 3; fi
echo "** New container port: $CONTAINER_PORT"

CONTAINER_ID=$(sudo docker run -d -p "$SERVICE_PORT:$CONTAINER_PORT" "$SERVICE")
if [ -z "$CONTAINER_ID" ]; then echo "** No container id"; exit 4; fi
echo "** New container id: $CONTAINER_ID"

echo "** Container running"
sleep 1

curl -I "http://127.0.0.1:$SERVICE_PORT/" | grep "HTTP/1.1" > /dev/null || exit 5
sudo docker stop "$CONTAINER_ID" || exit 6

sudo docker tag -f "$SERVICE" "$FINAL_SERVICE" || exit 7

sudo docker push "$FINAL_SERVICE" || exit 8

NEW_CONTAINER_ID=$(sudo docker create --restart=always -p $CONTAINER_PORT:$CONTAINER_PORT "$FINAL_SERVICE")
if [ -z "$NEW_CONTAINER_ID" ]; then echo "** No new container id"; exit 9; fi
echo "** New container id: $NEW_CONTAINER_ID"

CURRENT_CONTAINER_ID=$(sudo docker ps | grep "$SERVICE:latest" | awk '{print $1}' )
for ID in $CURRENT_CONTAINER_ID
do
  echo "ID: $ID"
  sudo docker stop "$ID" || exit 10
done

sudo docker start "$NEW_CONTAINER_ID" || exit 11
echo "** Started New container id: $NEW_CONTAINER_ID"


