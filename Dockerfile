ARG DOCKER_VERSION=stable
FROM python:3.5-alpine3.8 as build

ARG COMPOSE_VERSION=master

RUN apk --no-cache add git python3-dev binutils

# until docker/compose#6141 is merged
RUN git clone --branch musl https://github.com/andyneff/compose.git /app

WORKDIR /app

RUN adduser -h /home/user -s /bin/sh -D user
 COPY --chown=user:user requirements-build.txt /code/
RUN apk add --no-cache --virtual .deps ca-certificates gcc zlib-dev musl-dev libc-dev pwgen; \
    curl -fsSL https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py; \
    python3 /tmp/get-pip.py; \
    cd /tmp; \
    pip download -r /code/requirements-build.txt; \
    tar xzf PyInstaller*.tar.gz; \
    cd PyInstaller-*/bootloader; \
    python3 ./waf configure --no-lsb all; \
    cd ..; \
    python3 setup.py bdist_wheel; \
    mv dist/*.whl /; \
    cd /; \
    rm -rf /tmp/*; \
    apk del --no-cache .deps
WORKDIR /code/
RUN chown user:user /code
RUN pip install tox==2.1.1
COPY --chown=user:user requirements.txt /code/
COPY --chown=user:user requirements-dev.txt /code/
COPY --chown=user:user .pre-commit-config.yaml /code/
COPY --chown=user:user setup.py /code/
COPY --chown=user:user tox.ini /code/
COPY --chown=user:user compose /code/compose/
RUN su -c "tox -e py35 --notest" user; \
    /code/.tox/py35/bin/pip install /*.whl
COPY --chown=user:user . /code/

FROM docker:${DOCKER_VERSION}-git
MAINTAINER matfax <mat@fax.fyi>

RUN apk add --no-cache curl

COPY --from=build /usr/local/bin/docker-compose /usr/local/bin/docker-compose

ENV MUSL=1

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=latest

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/gofunky/compose" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
