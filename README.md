# SQL DB API over REST

A simple read only REST based DB API generating JSON ResultSets

## Installation

This POC is based on Flask, PostgreSQL, and D3.  To get going you need to have Python 3.4 or better.

    git clone git@git.repo/pathto/dbapi-flask.git && cd dbapi-flask

ensure that easy_install pip and virtualenv are installed:

    sudo apt-get install python3-setuptools python3-pip
    sudo pip3 install virtualenv
    sudo pip3 install setuptools --upgrade

Create and setup a virtual environment:

    mkvirtualenv --python=/usr/bin/python3 dbapi-flask
    workon dbapi-flask

Edit the virtualenv control file:

    vi $VIRTUAL_ENV/bin/postactivate

add lines:

    cd /path/to/dbapi-flask
    export APP_SETTINGS="config.DevelopmentConfig"

Jump into the virtualenv again to set the env vars:

    workon dbapi-flask

Now install all the dependencies:

    pip install -r requirements.txt

Configure:

edit config.py in particular SQLALCHEMY_BINDS to point to databases of your choice.

Run the server:

    python manage.py runserver

And point browser at http://localhost:5000
