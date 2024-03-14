#!/bin/bash

set -eo pipefail

default="mmta/alpine-glibc"
declare image_name="${1:-$default}" push="${2:-false}"

[ "$push" == "push" ] && push="true"

[ -z "$image_name" ] && echo "Usage: $0 <image_name> [push]" && exit 1

([ -z "$GLIBC_VERSION" ] || [ -z "$RUST_VERSION" ] || [ -z "$ALPINE_VERSION" ]) &&
  echo "[GLIBC_VERSION] [RUST_VERSION] [ALPINE_VERSION] env variable must be defined" && exit 1

echo "alpine version: $ALPINE_VERSION"
echo "glibc version: $GLIBC_VERSION"
echo "rust version: $RUST_VERSION"

echo "Building $image_name:latest ..."

docker build . -t $image_name \
  --build-arg ALPINE_VERSION=$ALPINE_VERSION \
  --build-arg GLIBC_VERSION=$GLIBC_VERSION

# take only the major and minor portion of the version, any revision/patch will just re-use the tag
# with an updated image

alpine_ver=$(echo $ALPINE_VERSION | cut -d. -f1,2)
glibc_ver=$(echo $GLIBC_VERSION | cut -d. -f1,2)
rust_ver=$(echo $RUST_VERSION | cut -d. -f1,2)

tag=${alpine_ver}_glibc-${glibc_ver}_rust-${rust_ver}

echo "Tagging the result with $image_name:$tag ..."

docker tag $image_name $image_name:${tag}

if [ "push" = "true" ]; then
  echo "Pushing $image_name:latest ..."
  docker push $image_name
  echo "Pushing $image_name:${tag} ..."
  docker push $image_name:${tag}
fi
