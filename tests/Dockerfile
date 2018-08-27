FROM compose
MAINTAINER matfax <mat@fax.fyi>

WORKDIR /app

ADD . /app

CMD ["docker-compose", "-f ./docker-compose.test.yml", "up", "--exit-code-from sut", "--build", "--abort-on-container-exit"]
