FROM sonarsource/sonar-scanner-cli:4.7 as sonars
FROM maven:3.8.6-eclipse-temurin-11 as maven
FROM atlassian/bamboo-agent-base:8.2.1 as ship

# Install and configure as ROOT
USER root

### Copy secrets
COPY secrets /etc/secrets
RUN chmod a+wr /etc/secrets

### Copy scripts
COPY scripts /scripts
RUN chmod a+wrx -R /scripts/*.sh # Required due to permission loss on Windows
#### Install using scripts
RUN /scripts/install.all.sh
#### Configure using scripts
RUN /scripts/config.all.sh

# Overwrite entrypoint command to start services before bamboo agent
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+wrx /entrypoint.sh
CMD ["/entrypoint.sh"]

### Install maven
ARG MVN_HOME=/usr/share/maven
COPY --from=maven ${MVN_HOME} ${MVN_HOME}
RUN ln -s ${MVN_HOME} /opt/maven

### Install Sonar Scanner
ARG SONAR_DIR=/opt/sonar-scanner
COPY --from=sonars ${SONAR_DIR} ${SONAR_DIR}
ENV SONAR_SCANNER_HOME ${SONAR_DIR}

# Update capabilities as RUN_USER
USER ${RUN_USER}
RUN /bamboo-update-capability.sh "system.builder.mvn3.Maven 3.8.6" ${MVN_HOME} \
    && /bamboo-update-capability.sh "system.git.executable" /usr/bin/git \
    && /bamboo-update-capability.sh "Docker" /usr/bin/docker \
    && /bamboo-update-capability.sh "system.builder.sos" ${SONAR_DIR}
