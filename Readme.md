# Minimal Alpine image with glibc

Yet another alpine docker image with glibc, this time also tracking Rust compiler version.

`latest` tag will always be based on `alpine:latest` image that includes the same `glibc` version used in the latest `rust:slim`.

The goal is to be able to do this multistage build in CI at any point in time without worrying about potential `glibc` version mismatch:

```Dockerfile
FROM rust AS builder
...
# insert steps to build the app
# the app will depend on the specific glibc version used in rust:latest.
...

FROM mmta/alpine-glibc AS base
...
# insert extra steps to customize the base Alpine image, e.g. apk add etc.
# mmta/alpine-glibc will be alpine:latest that has the same glibc version as rust:latest.
...

FROM base AS final
COPY --from=builder /app/target/release/app /app
...
# insert extra steps to init the env for this app, e.g. default directories, cfg files etc.
...
ENTRYPOINT [ "/app" ]
```

See [example](./example) for a test project that _should always_ built and run successfully.
