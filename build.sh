#!/usr/bin/env bash

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
GIT_SHA="$(git rev-parse HEAD)"
export GIT_SHA

docker buildx build --build-arg GIT_SHA="${GIT_SHA}" --tag "insanity_a:${GIT_SHA}" a/
docker buildx build --build-arg GIT_SHA="${GIT_SHA}" b/
