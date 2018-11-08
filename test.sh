#!/bin/bash

VERSIONS=6

HEADERS=""
VERBOSE=""

INT_PORT=80
BASE_PORT=8080

################################################################################
# Functions:

press() {
    echo $*
    echo "Press <return>"
    read
}

OLD() {
  for image in mjbright/docker-demo:1 mjbright/docker-demo:2 mjbright/k8s-demo:1 mjbright/k8s-demo:2; do
    echo "Testing image $image"

    EXT_PORT=8080
    docker run -d -p ${EXT_PORT}:${INT_PORT} $image
    ID=$(docker ps -ql)

    [ -z "$ID" ] && { echo "ERROR: Failed to launch container"; continue; }

    sleep 1
    curl 127.0.0.1:${EXT_PORT}
    press
    curl 127.0.0.1:${EXT_PORT}/ping
    press
    curl 127.0.0.1:${EXT_PORT}/map
    press

    docker stop $ID; docker rm $ID; 
  done
}

CLEANUP() {
    RUNNING_DEMO_C=$(docker ps | grep -E "docker-demo|k8s-demo" | awk '{ print $1;}')
    [ ! -z "$RUNNING_DEMO_C" ] && {
        CMD="docker stop $RUNNING_DEMO_C"
        echo $CMD
        eval $CMD
    }

    STOPPED_DEMO_C=$(docker ps -a | grep -E "docker-demo|k8s-demo" | awk '{ print $1;}')
    [ ! -z "$STOPPED_DEMO_C" ] && {
        CMD="docker rm $STOPPED_DEMO_C"
        echo $CMD
        eval $CMD
    }
}

################################################################################
# Args:

while [ ! -z "$1" ];do
    case $1 in
        -1) VERSIONS=1;;
   
        -c) CLEANUP; exit;;

        -h) HEADERS="-h";;
        -v) VERBOSE="-v";;
    esac
    shift
done

################################################################################
# Main:

CLEANUP

for image in mjbright/docker-demo mjbright/k8s-demo; do
    [ $image = "mjbright/docker-demo" ] && BASE_PORT=9000

    for version in $(seq $VERSIONS); do
        let EXT_PORT=BASE_PORT+version

        #docker pull $image:$version

        # expose container port on localhost:
        #docker run --rm -p ${EXT_PORT}:${INT_PORT} -d $image:$version

        # expose listen on container port:
        #docker run --rm -d $image:$version $HEADERS $VERBOSE -listen $INT_PORT
        #docker run -d $image:$version $HEADERS $VERBOSE -listen :$INT_PORT

        # expose listen on container port and expose on localhost: quel interet?
        docker run --rm -d -p ${EXT_PORT}:${INT_PORT} $image:$version $HEADERS $VERBOSE -listen :$INT_PORT
    done
done

