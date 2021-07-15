#!/bin/bash

## Needed env vars: DOCKER_REPO ELASTIC_APP_NAME APP_REVISION ELASTIC_PORT ELASTIC_CONTAINER_PORT 

ELASTIC_APP_NAME=elastic-poppins
ELASTIC_PORT=9200
ELASTIC_CONTAINER_PORT=9200
APP_REVISION=$(git rev-list --count HEAD)
REPO=${DOCKER_REPO}/${ELASTIC_APP_NAME}:${APP_REVISION}

#I think this is useless
APP_PORT=${ELASTIC_PORT}:${ELASTIC_CONTAINER_PORT}

build() {
	echo -e " ==> Building ${REPO} image."
	docker build -t ${REPO} .
	echo -e "Listing ${REPO} image."
	docker images
}

test() {
	echo -e " ==> Run ${REPO} image."
	docker run --name ${ELASTIC_APP_NAME} -p ${APP_PORT} &
	sleep 5
	docker logs ${ELASTIC_APP_NAME}
}
release(){
	echo -e " ==> Release ${REPO} image to docker registry."
	if [[ ! -z "$DOCKER_PWD" ]]; then
		cat ${DOCKER_PWD} | docker login --username ${DOCKER_USER} --password-stdin
	fi
	docker tag  ${REPO} ${REPO}
	docker push ${REPO}
}
clean(){
	echo -e "Cleaning local build environment."
	docker stop ${ELASTIC_APP_NAME} 2>/dev/null; true
	docker rm ${ELASTIC_APP_NAME}  2>/dev/null; true
	docker rmi ${REPO} 2>/dev/null; true
}
help(){
	echo -e ""
	echo -e "Please use \`make <target>' where <target> is one of"
	echo -e ""
	echo -e "  build		Builds the docker image."
	echo -e "  test		Tests image."
	echo -e "  release	Releases image."
	echo -e "  clean		Cleans local images."
	echo -e ""

}

if [[ "$1" == "build" ]]; then build;
elif [[ "$1" == "test" ]]; then test;
elif [[ "$1" == "release" ]];then release;
elif [[ "$1" == "clean" ]]; then clean;
elif [[ "$1" == "help" ]];then help;
else
	help
	exit -1
fi
