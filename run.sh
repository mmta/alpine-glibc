#!/bin/bash

# this checks the latest version of alpine, and glibc within rust:slim
# and then builds the image with appropriate tags

set -oex pipefail

tmp=$(mktemp)
export GITHUB_OUTPUT=$tmp

function cleanup {
  rm -rf $GITHUB_OUTPUT
}

trap cleanup EXIT

./scripts/ci-check_version.sh

source $GITHUB_OUTPUT

RUST_VERSION=$rust_version \
  GLIBC_VERSION=$glibc_version \
  ALPINE_VERSION=$alpine_version \
  ./scripts/ci-build_push.sh
