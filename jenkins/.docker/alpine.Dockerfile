ARG JENKINS_VERSION
FROM jenkins/jenkins:$JENKINS_VERSION
ARG DOCKER_VERSION

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

LABEL JENKINS_VERSION="$JENKINS_VERSION" DOCKER_VERSION="$DOCKER_VERSION"

USER root
RUN apk add --no-cache bash curl tar \
    && curl -o /tmp/docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
    && tar --strip-components=1 -xzvf /tmp/docker.tgz -C /usr/local/bin

USER ${user}
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt