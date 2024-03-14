#!/bin/sh

set -e
docker build . -t enterprise-app
docker run --rm enterprise-app
