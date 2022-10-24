#!/bin/bash

if [ "$DEBUG_MODE" == "true" ]; then
	set -x
fi

service docker start
service docker status

chmod a+wrx /var/run/docker.sock
ls -l /var/run/docker.sock

chmod a+wrx /var/run/docker
ls -l /var/run/docker
