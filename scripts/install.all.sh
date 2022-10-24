#!/bin/bash

{
  /scripts/install/prerequsites.sh
  /scripts/install/docker.sh
	
	# Clean up installations
	apt-get clean autoclean \
		&& apt-get autoremove -y \
		&& rm -rf /var/lib/apt/lists/*
} || {
  echo "Something went wrong"
  exit 1
}
