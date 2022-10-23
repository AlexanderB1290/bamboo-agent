#!/bin/bash

{
  /scripts/install/prerequsites.sh
  /scripts/install/docker.sh
} || {
  echo "Something went wrong"
  exit 1
}