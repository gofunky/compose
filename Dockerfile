ARG DOCKER_VERSION=stable
FROM docker:${DOCKER_VERSION}-git as build

ARG COMPOSE_VERSION

RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools

RUN pip install "docker-compose==${COMPOSE_VERSION}"

FROM docker:${DOCKER_VERSION}-git
MAINTAINER matfax <mat@fax.fyi>

RUN apk add --no-cache curl

COPY --from=build /usr/local/bin/docker-compose /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=latest

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/gofunky/compose" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
