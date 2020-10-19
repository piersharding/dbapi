
DOCKERFILE = Dockerfile
CONTAINER_EXISTS = $(shell docker ps -aqf ancestor=$(IMG))
IMG_EXISTS = $(shell docker images -q $(IMG))
APP_SETTINGS = config.DevelopmentConfig
URL_PREFIX =
FLASK_PORT = 8080


include docker.mak

#REGISTRY_HOST=myregistry.io
USERNAME=piersharding
NAME = nexuswbhk
IMG = $(NAME)


all: clean reqs build

clean:
ifneq "$(strip $(CONTAINER_EXISTS))" ""
	docker rm -f $(CONTAINER_EXISTS)
endif
ifneq "$(strip $(IMG_EXISTS))" ""
	docker rmi -f $(IMG)
endif

reqs:
	pipenv run pip freeze > requirements.txt

# build: reqs
# 	docker build -t $(IMG) -f $(DOCKERFILE) .
# 	docker tag $(IMG):latest piersharding/$(IMG):latest
# 	docker push piersharding/$(IMG):latest

test: build
	APP_SETTINGS="$(APP_SETTINGS)" URL_PREFIX="$(URL_PREFIX)" FLASK_PORT="$(FLASK_PORT)" pipenv run python manage.py runserver

test_docker: build
	docker run -ti --name "$(NAME)" \
	 -p $(FLASK_PORT):$(FLASK_PORT) \
	 -v /dev/log:/dev/log \
	 -e APP_SETTINGS="$(APP_SETTINGS)" \
	 -e  URL_PREFIX="$(URL_PREFIX)" \
	 -e FLASK_PORT="$(FLASK_PORT)" \
	 -d $(IMG)
	@echo "go to http://localhost:$(FLASK_PORT)/"

test_gunicorn:
	 export APP_SETTINGS="$(APP_SETTINGS)" URL_PREFIX="$(URL_PREFIX)" FLASK_PORT="$(FLASK_PORT)"  && pipenv run gunicorn -w 5  --access-logfile - --bind 0.0.0.0:$(FLASK_PORT) app:app
