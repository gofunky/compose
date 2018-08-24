ARG DOCKER_VERSION=stable
FROM docker:${DOCKER_VERSION}-git
MAINTAINER matfax <mat@fax.fyi>

COPY /usr/local/bin/docker-compose /usr/local/bin/docker-compose

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=latest

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/gofunky/compose" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
