ARG DOCKER_VERSION=stable
FROM docker:${DOCKER_VERSION}-git
MAINTAINER matfax <mat@fax.fyi>

ARG COMPOSE_VERSION

ADD https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose
