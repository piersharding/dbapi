
NAME = dbapi
IMG = $(NAME)_img
DOCKERFILE = Dockerfile
CONTAINER_EXISTS = $(shell docker ps -aqf ancestor=$(IMG))
IMG_EXISTS = $(shell docker images -q $(IMG))
APP_SETTINGS = config.DevelopmentConfig
URL_PREFIX = 
FLASK_PORT = 80
DEVICE ?= $(shell ip link show | grep BROADCAST | grep -v -E 'lxcbr|docker|br-|vboxnet' | tail -1 | cut -d: -f2 | tr -d '[:space:]')
DB_IP = $(shell ifconfig ${DEVICE} | grep 'inet ' | awk '{print $$2}')

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
	docker run --rm -ti --name "$(NAME)" \
	 -h '$(NAME).local.net' \
	 --add-host postgres.local.net:$(DB_IP) \
	 -p $(FLASK_PORT):$(FLASK_PORT) \
	 -v /dev/log:/dev/log \
	 -e APP_SETTINGS="$(APP_SETTINGS)" \
	 -e  URL_PREFIX="$(URL_PREFIX)" \
	 -e FLASK_PORT="$(FLASK_PORT)" \
	 -d $(IMG)
	@echo "IP for $(NAME) is: "
	@echo `docker inspect --format "{{.NetworkSettings.IPAddress}}" $(NAME)`
	@echo "Put "`docker inspect --format "{{.NetworkSettings.IPAddress}}" $(NAME)`" $(NAME).local.net $(NAME) in your /etc/hosts file."
	@echo "And then go to http://dbapi.local.net:$(FLASK_PORT)/"

test_gunicorn:
	 URL_PREFIX="$(URL_PREFIX)" FLASK_PORT="$(FLASK_PORT)" gunicorn -w 5  --access-logfile - --bind 0.0.0.0:${FLASK_PORT} app:app
