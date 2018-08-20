ARG DOCKER_VERSION=stable
FROM docker:${DOCKER_VERSION}-git as build

ARG COMPOSE_VERSION

RUN apk --no-cache add python3 && \
    python3 -m ensurepip && \
    pip3 install --upgrade pip setuptools

# until docker/compose#6141 is merged
RUN git clone --branch musl https://github.com/andyneff/compose.git /compose
RUN cd /compose && \
    pip --no-cache-dir install -r requirements.txt -r requirements-dev.txt pyinstaller && \
    git rev-parse --short HEAD > compose/GITSHA && \
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
