SCRIPT_NAME = ip_latlong.py
DOCKER_IMAGE_NAME = ip_latlong

.PHONY: all clean doc docker_build docker lint reqs setup

all: docker

reqs:
	pipreqs --force .

setup: requirements.txt
	pip install -r requirements.txt

docker_build:
	docker build -t $(DOCKER_IMAGE_NAME) `cat .env | sed 's/^/--build-arg /'` .

docker: docker_build
	docker save $(DOCKER_IMAGE_NAME):latest | gzip > $(DOCKER_IMAGE_NAME)-docker_image.tar.gz

doc:
	doxygen doxy.config

lint:
	flake8 --config .flake8

clean:
	rm -f __pycache__
	rm -rf $(DOCKER_IMAGE_NAME)-docker_image.tar.gz
