
NAME = dbapi
IMG = $(NAME)_img
FLAVOUR = ubuntu
DOCKERFILE = Dockerfile.$(FLAVOUR)
CONTAINER_EXISTS = $(shell docker ps -aqf ancestor=$(IMG))
IMG_EXISTS = $(shell docker images -q $(IMG))
APP_SETTINGS = config.DevelopmentConfig
URL_PREFIX = 
FLASK_PORT = 5000

all: $(IMG).tar

clean:
ifneq "$(strip $(CONTAINER_EXISTS))" ""
	docker rm -f $(CONTAINER_EXISTS)
endif
ifneq "$(strip $(IMG_EXISTS))" ""
	docker rmi -f $(IMG)
endif

build:
	rm -f $(IMG).tar
	docker build -t $(IMG) -f $(DOCKERFILE) .

$(IMG).tar: build
	docker save -o $(IMG).tar $(IMG)

test: build
	APP_SETTINGS="$(APP_SETTINGS)" URL_PREFIX="$(URL_PREFIX)" FLASK_PORT="$(FLASK_PORT)" python manage.py runserver

test_docker: build
	docker run --rm -ti --name "$(NAME)" -h '$(NAME).local.net' -v /dev/log:/dev/log -e APP_SETTINGS="$(APP_SETTINGS)" -e  URL_PREFIX="$(URL_PREFIX)" -e FLASK_PORT="$(FLASK_PORT)" $(IMG) /bin/bash

test_gunicorn:
	 URL_PREFIX="$(URL_PREFIX)" FLASK_PORT="$(FLASK_PORT)" gunicorn -w 5  --access-logfile - --bind 0.0.0.0:${FLASK_PORT} app:app
