#!/bin/bash

{
  /scripts/start/docker.sh
} || {
  echo "Something went wrong"
  exit 1
}