#!/bin/bash

set -e

CONFIG_FILE="/data/config.yml"
RUNNER_FILE="/data/.runner"

if [ ! -f "$CONFIG_FILE" ]; then
  forgejo-runner generate-config > "$CONFIG_FILE"
fi

if [ -z "$FORGEJO_LABELS" ]; then
  FORGEJO_LABELS="ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest,ubuntu-24.04:docker://docker.gitea.com/runner-images:ubuntu-24.04,docker:docker://data.forgejo.org/oci/node:lts"
fi

if [ ! -f "$RUNNER_FILE" ]; then
  /bin/forgejo-runner -c "$CONFIG_FILE" register \
    --no-interactive \
    --instance "$FORGEJO_INSTANCE_URL" \
    --token "$FORGEJO_RUNNER_REGISTRATION_TOKEN" \
    --name "$FORGEJO_RUNNER_NAME" \
    --labels "$FORGEJO_LABELS"
fi

if [ -f "$RUNNER_FILE" ]; then
  tmp_runner_file="${RUNNER_FILE}.tmp"
  jq \
    --arg name "$FORGEJO_RUNNER_NAME" \
    --arg address "$FORGEJO_INSTANCE_URL" \
    --arg labels "$FORGEJO_LABELS" \
    '.name = $name | .address = $address | .labels = ($labels | split(","))' "$RUNNER_FILE" > "$tmp_runner_file"
  mv "$tmp_runner_file" "$RUNNER_FILE"
fi

exec /bin/forgejo-runner -c "$CONFIG_FILE" daemon
