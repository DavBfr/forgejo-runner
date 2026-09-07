FROM data.forgejo.org/forgejo/runner:13@sha256:c4af85fd9f0dd03788676a534781a87c71aa2c6a37737143e017eb94d4312952 AS base

FROM alpine:3@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

RUN apk add --no-cache git bash jq

COPY --from=base /bin/forgejo-runner /bin/forgejo-runner
ADD --chmod=755 entrypoint.sh /bin/entrypoint.sh

ENV HOME=/data
ENV DOCKER_HOST=unix:///var/run/docker.sock

WORKDIR /data

VOLUME ["/data"]

CMD ["/bin/entrypoint.sh"]
