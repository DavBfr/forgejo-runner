FROM data.forgejo.org/forgejo/runner:13@sha256:a8543a45fe62bebef0534d5c223cf485d3294e6dd2e42a82dbcbfd40c54a6a22 AS base

FROM alpine:3@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

RUN apk add --no-cache git bash jq

COPY --from=base /bin/forgejo-runner /bin/forgejo-runner
COPY --chmod=755 entrypoint.sh /bin/entrypoint.sh

ENV HOME=/data
ENV DOCKER_HOST=unix:///var/run/docker.sock

WORKDIR /data

VOLUME ["/data"]

CMD ["/bin/entrypoint.sh"]
