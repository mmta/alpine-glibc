#!/bin/bash

set -eou pipefail

default="mmta/alpine-glibc"
declare image_name="${1:-$default}" push="${2:-false}"

[ "$push" == "push" ] && push="true"

[ -z "$image_name" ] && echo "Usage: $0 <image_name> [push]" && exit 1

docker build -f Dockerfile.vers . -t get-ver 2>/dev/null

out=$(docker run get-ver)
glibc_ver=$(echo $out | cut -d' ' -f1 | cut -d= -f2)
rust_ver=$(echo $out | cut -d' ' -f2 | cut -d= -f2)

alpine_ver=$(docker run alpine sh -c "cat /etc/os-release | grep VERSION_ID | cut -d= -f2")

echo "alpine version: $alpine_ver"
echo "glibc version: $glibc_ver"
echo "rust version: $rust_ver"

echo "Building $image_name:latest ..."

docker build . -t $image_name \
  --build-arg ALPINE_VERSION=$alpine_ver \
  --build-arg GLIBC_VERSION=$glibc_ver

# take only the major and minor portion of the version, any revision/patch will just re-use the tag
# with an updated image

alpine_ver=$(echo $alpine_ver | cut -d. -f1,2)
glibc_ver=$(echo $glibc_ver | cut -d. -f1,2)

tag=${alpine_ver}_glibc-${glibc_ver}_rust-${rust_ver}

echo "Tagging the result with $image_name:$tag ..."

docker tag $image_name $image_name:${tag}

if [ "push" = "true" ]; then
  echo "Pushing $image_name:latest ..."
  docker push $image_name
  echo "Pushing $image_name:${tag} ..."
  docker push $image_name:${tag}
fi
