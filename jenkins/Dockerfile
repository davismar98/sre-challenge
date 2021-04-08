FROM jenkins/jenkins:lts

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY --chown=jenkins:jenkins jcac.yml /var/jenkins_home/jcac.yml
COPY --chown=jenkins:jenkins init-scripts /usr/share/jenkins/ref/init.groovy.d

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

ENV CASC_JENKINS_CONFIG=/var/jenkins_home/jcac.yml

VOLUME /var/jenkins_home
 