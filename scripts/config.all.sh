#!/bin/bash

{
  /scripts/config/docker.sh
} || {
  echo "Something went wrong"
  exit 1
}