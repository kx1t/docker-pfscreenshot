#!/bin/bash
#
set -x

[[ "$1" != "-" ]] && BRANCH="$1"
[[ "$BRANCH" == "-" ]] && BRANCH=dev

[[ "$BRANCH" == "main" ]] && TAG="latest" || TAG="$BRANCH"

# rebuild the container
pushd ~/docker-pfscreenshot
git checkout $BRANCH || exit 2

git pull -a
docker buildx build --compress --push $2 --platform linux/armhf,linux/arm64 --tag kx1t/pfscreenshot:$TAG .
popd
