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

### Install maven
COPY --from=maven /opt/maven /opt/maven
RUN ln -s /opt/maven /usr/share/maven


# Update capabilities as RUN_USER
USER ${RUN_USER}