#!/bin/sh


X=`sudo docker ps -a | grep dbapi`
if [ "$X" = "" ]; then
  echo "no container running..."
else
  echo "removing running container ..."
  sudo docker stop dbapi
  sudo docker rm -f dbapi
fi

X=`sudo docker images | grep dbapi_img`
if [ "$X" = "" ]; then
  echo "no image ..."
else
  if [ -n "$1" ]; then
    echo "removing image ..."
    sudo docker rmi dbapi_img
  else
    echo "leaving image..."
  fi
fi

sudo docker build -t dbapi_img .
