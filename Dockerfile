ARG DOCKER_VERSION=stable
FROM python:3.6.6-alpine3.8 as build

ARG COMPOSE_VERSION=master

RUN apk --no-cache add git
RUN ln -s /lib /lib64 && ln -s /lib/libc.musl-x86_64.so.1 ldd && ln -s /lib/ld-musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
RUN pip install tox

# until docker/compose#6141 is merged
RUN git clone --branch musl https://github.com/andyneff/compose.git /code/compose

WORKDIR /code/compose

RUN tox -e py36 --notest && \
    mv /code/.tox/py36/bin/docker-compose /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

FROM docker:${DOCKER_VERSION}-git
MAINTAINER matfax <mat@fax.fyi>

RUN apk add --no-cache curl

COPY --from=build /usr/local/bin/docker-compose /usr/local/bin/docker-compose

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=latest

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/gofunky/compose" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
