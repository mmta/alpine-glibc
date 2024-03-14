#!/bin/bash

set -oe pipefail

docker build -f Dockerfile.vers . -t get-ver 2>/dev/null

out=$(docker run get-ver)

glibc_ver=$(echo $out | cut -d' ' -f1 | cut -d= -f2)
rust_ver=$(echo $out | cut -d' ' -f2 | cut -d= -f2)
alpine_ver=$(docker run alpine sh -c "cat /etc/os-release | grep VERSION_ID | cut -d= -f2")

# take only the major and minor portion of the version, any revision/patch will just re-use the tag

alpine_tag=$(echo $alpine_ver | cut -d. -f1,2)
glibc_tag=$(echo $glibc_ver | cut -d. -f1,2)
rust_tag=$(echo $rust_ver | cut -d. -f1,2)
tag=${alpine_tag}_glibc-${glibc_tag}_rust-${rust_tag}

echo "alpine_version=$alpine_ver"
echo "glibc_version=$glibc_ver"
echo "rust_version=$rust_ver"
echo "image tag: $tag"

echo "alpine_version=$alpine_ver" >>$GITHUB_OUTPUT
echo "glibc_version=$glibc_ver" >>$GITHUB_OUTPUT
echo "rust_version=$rust_ver" >>$GITHUB_OUTPUT
echo "tag=$tag" >>$GITHUB_OUTPUT
