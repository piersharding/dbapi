#!/bin/sh

# load the environment from the secret volume
if [ -f /etc/secret-volume/environment ]; then
    echo "Found secret environment"
    . /etc/secret-volume/environment
fi

export FLASK_PORT=${FLASK_PORT:-5000}

cd /src/
gunicorn -w 10 --bind 0.0.0.0:${FLASK_PORT} app:app
