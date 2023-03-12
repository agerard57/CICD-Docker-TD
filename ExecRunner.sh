#!/bin/bash

source .env

sudo gitlab-runner register \
    --url http://agerard57.com/ \
    --registration-token "${REGISTRATION_TOKEN}" \
    --executor docker \
    --description "Docker Runner for Docker TD" \
    --docker-image "docker:stable" \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
