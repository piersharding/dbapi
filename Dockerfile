FROM xenial

MAINTAINER Piers Harding "piers@catalyst.net.nz"

ENV LANG en_NZ.UTF-8
ENV LANGUAGE en_NZ.UTF-8
ENV LC_ALL en_NZ.UTF-8
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV APP_SETTINGS config.DevelopmentConfig


RUN \
    echo "Setting locales  ..." && /usr/sbin/locale-gen en_US.UTF-8 && \
    /usr/sbin/locale-gen en_NZ.UTF-8 && \
    echo "Setting timezone ..." &&  /bin/echo 'Pacific/Auckland' | sudo tee /etc/timezone && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure --frontend noninteractive tzdata && \
    DEBIAN_FRONTEND=noninteractive apt-add-repository -y ppa:ubuntugis/ubuntugis-unstable && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y python3-gdal python3-setuptools libpq-dev python3-dev libxml2-dev libxslt1-dev zlib1g-dev python3-pip phantomjs && \
    apt-get clean -y


# Add and install Python modules
ADD ./requirements.txt /src/requirements.txt

RUN cd /src; pip3 install --upgrade pip; pip3 install -r requirements.txt

# Bundle app source
ADD ./*.py  /src/
ADD ./static /src/static/
ADD ./templates /src/templates/
ADD ./boot.sh /

# Expose
EXPOSE  5000

# Run
CMD ["/boot.sh"]
