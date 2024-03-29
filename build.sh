#!/usr/bin/env bash

set -xeuo pipefail

# Errors are expected in this script.
set +e

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
GIT_SHA="$(git rev-parse HEAD)"
export GIT_SHA

remove_cache() {
    # Remove cached images for demonstration.
    docker image rm "insanity_a:${GIT_SHA}" "insanity_b:${GIT_SHA}" || echo "OK"
    docker system prune -f
    docker buildx prune -f
}

echo "
################################################################################
################################################################################
# Case 1: \`docker build\` WITHOUT buildkit.
#
# NOTE: this does work but cannot be used with `--platform`.
################################################################################
################################################################################
"
export DOCKER_BUILDKIT=0
remove_cache
docker build --build-arg GIT_SHA="${GIT_SHA}" --tag "insanity_a:${GIT_SHA}" a/
docker images insanity_a
docker build --build-arg INSANITY_A_VERSION="${GIT_SHA}" --tag "insanity_b:${GIT_SHA}" b/

echo "
################################################################################
################################################################################
# Case 2: \`docker compose\` WITHOUT buildkit.
#
# NOTE: this does work but cannot be used with `services: b: platform: ...`.
################################################################################
################################################################################
"
export DOCKER_BUILDKIT=0
remove_cache
docker compose -f ./docker-compose.yml build insanity_a
docker images insanity_a
docker compose -f ./docker-compose.yml build insanity_b

echo "
################################################################################
################################################################################
# Case 3: \`docker build\` WITH buildkit.
################################################################################
################################################################################
"
export DOCKER_BUILDKIT=1
remove_cache
docker build --build-arg GIT_SHA="${GIT_SHA}" --tag "insanity_a:${GIT_SHA}" a/
docker images insanity_a
docker build --build-arg INSANITY_A_VERSION="${GIT_SHA}" --tag "insanity_b:${GIT_SHA}" b/

echo "
################################################################################
################################################################################
# Case 4: \`docker compose\` WITH buildkit.
#
# NOTE: macos requires buildkit
################################################################################
################################################################################
"
export DOCKER_BUILDKIT=1
remove_cache
docker compose -f ./docker-compose.yml build insanity_a
docker images insanity_a
docker compose -f ./docker-compose.yml build insanity_b

echo "
################################################################################
################################################################################
# Case 5: \`docker buildx build\` (REQUIRES buildkit).
#
# NOTE: macos does not provide \`docker build\`, only \`docker buildx\`.
################################################################################
################################################################################
"
unset DOCKER_BUILDKIT
remove_cache
docker buildx build --load --build-arg GIT_SHA="${GIT_SHA}" --tag "insanity_a:${GIT_SHA}" a/
docker images insanity_a
docker buildx build --load --build-arg INSANITY_A_VERSION="${GIT_SHA}" --tag "insanity_b:${GIT_SHA}" b/

echo '
################################################################################
################################################################################
# Case 6: \`docker buildx build\` (REQUIREs buildkit) using `--cache-from`
################################################################################
################################################################################
'
unset DOCKER_BUILDKIT
remove_cache
docker buildx build --load --build-arg GIT_SHA="${GIT_SHA}" --tag "insanity_a:${GIT_SHA}" a/
docker images insanity_a
docker buildx build --load --build-arg INSANITY_A_VERSION="${GIT_SHA}" "--cache-from=insanity_a:${GIT_SHA}" --tag "insanity_b:${GIT_SHA}" b/

# Remove cache for next test
remove_cache
