#!/bin/sh

X=`sudo docker ps -a | grep dbapi`

if [ "$X" = "" ]; then
  echo "no container running..."
else
  echo "removing running container ..."
  sudo docker stop dbapi
  sudo docker rm dbapi
fi

sudo docker run --name "dbapi" -h 'dbapi.local.net' \
  -e APP_SETTINGS="config.DevelopmentConfig" \
  -e FLASK_PORT="5000" \
  -p 5000:5000 \
  -v /dev/log:/dev/log \
  -d dbapi_img
