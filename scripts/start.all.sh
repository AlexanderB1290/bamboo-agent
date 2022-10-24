#!/bin/bash

export DEBUG_MODE=false

{
  /scripts/start/docker.sh
} || {
  echo "Something went wrong"
  exit 1
}
