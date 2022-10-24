#!/bin/bash

if [ "$DEBUG_MODE" == "true" ]; then
	set -x
fi

DOC_USERNAME=<docker_hub_username>

# Add user to groups
usermod -aG docker $RUN_USER
usermod -aG root $RUN_USER
usermod -aG sudo $RUN_USER

# daemon.json configuration
mkdir -p /etc/docker
touch /etc/docker/daemon.json
cat <<EOT >> /etc/docker/daemon.json
{
  "mtu": 1200,
  "storage-driver": "vfs",
  "log-opts": {
      "max-size": "100m",
      "max-file": "5"
  }
}
EOT
chown -R root:docker /etc/docker

### Bypass Docker pull rate limit by authenticating
cat /etc/secrets/docker.pwd | docker login --username $DOC_USERNAME --password-stdin

cp -R /root/.docker $BAMBOO_AGENT_HOME/.docker
chmod a+wr $BAMBOO_AGENT_HOME/.docker
chown -R $RUN_USER:$RUN_GROUP $BAMBOO_AGENT_HOME/.docker
