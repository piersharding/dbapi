#!/bin/sh

export FLASK_PORT=${FLASK_PORT:-5000}

gunicorn -w 4 --log-syslog --log-syslog-to 'unix:///dev/log#dgram' --bind 0.0.0.0:${FLASK_PORT} app:app
