# Bamboo agent - Ready to run!

A Bamboo Agent is a service that can run job builds. Each agent has a defined set of capabilities and can run builds only for jobs whose requirements match the agent's capabilities.
To learn more about Bamboo, see: https://www.atlassian.com/software/bamboo

The following Bamboo docker image agents is extension of [Atlassian's Bamboo base image](https://bitbucket.org/atlassian-docker/docker-bamboo-agent-base/src/master/).

# Overview

This Docker container makes it easy to get a Bamboo Remote Agent up and running. It is intended to be used as a ready to run Bamboo agent in K8S cluster and have the following capabilities:

* JDK 11
* Git & Git LFS
* Maven 3.8.6
* Python 3
* Sonar Scanner 4.7
* Docker in Docker (DinD) 20.10

# Prerequisites

The following prerequisites are required in addition to run this docker image:
* Installed helm
* Installed and configured K8S cluster. Note that the configuration describe the process using ```microk8s```.
* Persistent volume and claim for caching Bamboo jobs and docker images

# Configuration

Before you can start using the docker image as full fledge agent, there are some additional configurations that need to be performed.

1. Make sure your Bamboo server is running and has remote agents support enabled. To enable it, go to **Administration > Agents console**.
2. Update Docker Hub credentials to avoid docker pull rate limit.
   * Navigate to the file ```secrets/dockerpwd.txt``` and provide your password or Docker Hub authentication token (recommended).
   * Update the authentication username for Docker Hub in the file ```scripts/config/docker.sh```
3. Create K8S secret containing Bamboo security token
    ```shell
    kubectl create secret generic bamboo-agent-security-token --from-literal=security-token=<Bamboo_Server_Token>
    ```
4. Create K8S local persistent volume and claim for caching Bamboo builds and docker images.
   * Update the provided volume definitions from the ```k8s``` folder - change the capacity, host path or type.
   * Create the persistent volumes and their corresponding claims.
   ```shell
   kubectl create -f k8s/build-dir-caching.yaml
   kubectl create -f k8s/mvn-docker-caching.yaml
   ```
5. Build and push your docker image to Docker Hub private repository.
    ```shell
    docker build -t <docker hub repo>/<image name>:<image version> .
    docker push <docker hub repo>/<image name>:<image version>
    ```
6. Update the ```helm-chart/values/values.yaml``` for the updated Helm charts or create a new values to use.
   * Provide your docker image from Docker Hub
   * Provide your credentials for Docker Hub
7. Deploy the Bamboo agents using the updated Helm Charts
    ```shell
    helm install bamboo-agent helm-chart/bamboo-agent/ --values helm-chart/bamboo-agent/values.yaml --wait
    ```

# Extending the capabilities of the image

This Docker image contains most used capabilities for building docker images and Maven project. If you need additional capabilities you can extend the image to suit your needs. Using the scripts from their corresponding the folder, new capabilities can be installed, configured, started and stopped.
```tree
scripts/
├─ install/
├─ config/
├─ start/
├─ install.all.sh
├─ config.all.sh
├─ start.all.sh
```

## Installation scripts

To install a new capability create a shell script under the folder ```scripts/install``` with an appropriate name and add the required commands to install the capability. 

After that add the path to the script to ```scripts/install.all.sh```, so the capability can be installed during building of the docker image. This installation script is ran first. If you require additional packages, you can add them to the ```scripts/install/preqreuisites.sh``` which is taking care of installing any additional packages.

## Configuration scripts

To configure an installed capability create a shell script under the folder ```scripts/config``` with an appropriate name and add the required commands to configure the installed capability.

After that add the path to the script to ```scripts/config.all.sh```, so the installed capability can be configured after its installation during building of the docker image. Note that first the script for installing all capabilities is run before running the script for configuring the capabilities.

## Start-Up scripts

To start any services or run specific commands during starting of the container, create a script under the folder ```scripts/start``` with an appropriate name and add the required commands for starting or running commands during start up of the container.

After that add the path to script to ```scripts/start.all.sh```, which is run when the container is starting, but before starting the Bamboo agent executable. 

Note the following:
   * The start-up script need to complete under ```120 seconds (2 minute)```, otherwise you will need to edit the values for ```startupProbe``` and ```readinessProbe``` to increase the timeout limit.
   * Running start-up scripts after starting the Bamboo agent, need to be run without elevated permissions, as non-root user.

