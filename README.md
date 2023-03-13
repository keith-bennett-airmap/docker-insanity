# docker-insanity

Docker is deperacating building without BuildKit. This represents a significant
problem for a project tree.

Importantly, **Docker on macOS does not support building without BuildKit**.

# Case 1
Case 1 is `docker build` WITHOUT buildkit. Not using BuildKit is currently the
default on Linux. However, it presents a warning:
```
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            BuildKit is currently disabled; enable it by removing the DOCKER_BUILDKIT=0
            environment-variable.
```

# Case 2
Case 2 is `docker compose` WITHOUT BuildKit. Not using BuildKit is currently the
default on Linux. However, it presents a warning:
```
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            BuildKit is currently disabled; enable it by removing the DOCKER_BUILDKIT=0
            environment-variable.
```

# Case 3
Case 3 is `docker build` WITH BuildKit.

I'm not sure how to reproduce this with `docker buildx` but this proves that _it
should be possible_. Somehow, `DOCKER_BUILD_KIT=1 docker build` enables the
BuildKit builder to see previous images.

# Case 4
Case 4 uses BuildKit via `DOCKER_BUILDKIT=1 docker compose`. Importantly **macOS
must use BuildKit**.

# Case 5
Case 5 uses BuildKit via `docker buildx build`. Importantly **macOS must use
`docker buildx`**.

# Summary
Note Docker BuildKit _can_ see previous images if using `docker build` instead
of `docker buildx build`. I'm not sure how to explicitly enable that behavior
for `docker buildx build` or for `docker compose`.
