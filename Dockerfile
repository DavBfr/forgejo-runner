FROM data.forgejo.org/forgejo/runner:13@sha256:568cea8c15ddc01fc8f330124892f572af7db37fa28344a2c1914405793bf61d AS base

FROM alpine:3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

RUN apk add --no-cache git bash jq

COPY --from=base /bin/forgejo-runner /bin/forgejo-runner
COPY --chmod=755 entrypoint.sh /bin/entrypoint.sh

ENV HOME=/data
ENV DOCKER_HOST=unix:///var/run/docker.sock

WORKDIR /data

VOLUME ["/data"]

CMD ["/bin/entrypoint.sh"]
