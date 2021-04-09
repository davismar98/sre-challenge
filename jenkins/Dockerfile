FROM jenkins/jenkins:2.277.2-lts-jdk11

USER root
RUN apt-get update && apt-get install -y apt-utils apt-transport-https \
       ca-certificates curl gnupg2 \
       software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y docker-ce-cli

USER jenkins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY --chown=jenkins:jenkins jcac.yml /var/jenkins_home/jcac.yml
COPY --chown=jenkins:jenkins init-scripts /usr/share/jenkins/ref/init.groovy.d

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

ENV CASC_JENKINS_CONFIG=/var/jenkins_home/jcac.yml

VOLUME /var/jenkins_home