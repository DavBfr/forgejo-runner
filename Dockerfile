FROM data.forgejo.org/forgejo/runner:12@sha256:d85b420efea6f0137fe03f285b05df73e0c34cfbfc2c6a96d22cc52f38106d8c AS base

FROM alpine:3@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

RUN apk add --no-cache git bash jq

COPY --from=base /bin/forgejo-runner /bin/forgejo-runner
ADD --chmod=755 entrypoint.sh /bin/entrypoint.sh

ENV HOME=/data
ENV DOCKER_HOST=unix:///var/run/docker.sock

WORKDIR /data

VOLUME ["/data"]

CMD ["/bin/entrypoint.sh"]
