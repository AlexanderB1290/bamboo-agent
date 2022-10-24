#!/bin/bash

if [ "$DEBUG_MODE" == "true" ]; then
	set -x
fi

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl gnupg lsb-release \
  nano vim sudo git
