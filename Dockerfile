FROM data.forgejo.org/forgejo/runner:13@sha256:ca3d5eea46004789a175d1369eec6829d3ea9bfbe2011a06625b4bdaa55f7552 AS base

FROM alpine:3@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

RUN apk add --no-cache git bash jq

COPY --from=base /bin/forgejo-runner /bin/forgejo-runner
ADD --chmod=755 entrypoint.sh /bin/entrypoint.sh

ENV HOME=/data
ENV DOCKER_HOST=unix:///var/run/docker.sock

WORKDIR /data

VOLUME ["/data"]

CMD ["/bin/entrypoint.sh"]
