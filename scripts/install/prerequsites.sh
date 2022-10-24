#!/bin/bash

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl gnupg lsb-release \
  nano vim sudo git
