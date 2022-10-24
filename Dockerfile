# Atlassian bamboo agent base image is based on eclipse-temurin:11 image
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
ENV MAVEN_HOME=/usr/share/maven
COPY --from=maven /usr/share/maven ${MAVEN_HOME}
RUN ln -s ${MAVEN_HOME} /opt/maven

### Install Sonar Scanner
ENV SONAR_SCANNER_HOME /opt/sonar-scanner
COPY --from=sonars /opt/sonar-scanner ${SONAR_SCANNER_HOME}

# Update capabilities as RUN_USER
USER ${RUN_USER}
RUN /bamboo-update-capability.sh "system.builder.mvn3.Maven 3" ${MAVEN_HOME} \
    && /bamboo-update-capability.sh "system.git.executable" /usr/bin/git \
    && /bamboo-update-capability.sh "Docker" /usr/bin/docker \
    && /bamboo-update-capability.sh "system.builder.sos" ${SONAR_SCANNER_HOME}
