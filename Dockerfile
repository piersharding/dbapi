FROM python:3

MAINTAINER Piers Harding "piers@catalyst.net.nz"

ENV LANG en_NZ.UTF-8
ENV LANGUAGE en_NZ.UTF-8
ENV LC_ALL en_NZ.UTF-8
ENV HOME /app
ENV DEBIAN_FRONTEND noninteractive
ENV APP_SETTINGS config.DevelopmentConfig


# Add and install Python modules
ADD ./requirements.txt /src/requirements.txt

RUN mkdir -p /app; cd /src; pip3 install -r requirements.txt

# Bundle app source
ADD ./*.py  /app/
ADD ./static /app/static/
ADD ./templates /app/templates/
ADD ./boot.sh /

# Expose
EXPOSE  5000

# Run
CMD ["/boot.sh"]
