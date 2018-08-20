ARG DOCKER_VERSION=stable
FROM python:3.7.0-alpine3.8 as build

ARG COMPOSE_VERSION=master

RUN apk --no-cache add git && \
    pip3 install --upgrade pip setuptools tox

# until docker/compose#6141 is merged
RUN git clone --branch musl https://github.com/andyneff/compose.git /code/compose

WORKDIR /code/compose

RUN tox --notest && \
    ln -s /lib /lib64 && ln -s /lib/libc.musl-x86_64.so.1 ldd && ln -s /lib/ld-musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && \
    pyinstaller docker-compose.spec && \
    mv dist/docker-compose-musl-Linux-x86_64 /usr/local/bin/docker-compose

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
