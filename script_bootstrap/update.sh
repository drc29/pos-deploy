#!/bin/bash

source $(dirname "$0")/function.sh
# Base Directory: All Directories will be below this point
DIRECTORY=pos
DB_DATA=docker-datas
BASE_DIRECTORY=/opt
POS_DIRECTORY=$BASE_DIRECTORY/$DIRECTORY
DB_DIRECTORY=$BASE_DIRECTORY/$DIRECTORY/$DB_DATA/pos-db


echo "...running update"
echo "...going to $POS_DIRECTORY"
cd $POS_DIRECTORY

echo "...pulling latest images"
docker compose -f docker-compose-linux.yaml pull
loading_icon 15 "...waiting to properly load new docker images"

echo "...updating docker container to use new docker image"
cd $POS_DIRECTORY
docker compose -f docker-compose-linux.yaml up -d
loading_icon 15 "...waiting containers to properly initialize"

echo "...done updating the docker images"

