#!/bin/bash

export DEBUG_MODE=false

{
  /scripts/config/docker.sh
} || {
  echo "Something went wrong"
  exit 1
}
