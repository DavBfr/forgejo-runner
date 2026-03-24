#!/bin/bash

set -e

CONFIG_FILE="/data/config.json"
RUNNER_FILE="/data/.runner"

apply_config_env_overrides() {
  local has_overrides=false
  local env_name
  local env_path
  local env_value
  local path_json
  local tmp_config_file

  for env_name in $(compgen -e); do
    case "$env_name" in
      CONFIG__*|config__*)
        has_overrides=true
        break
        ;;
    esac
  done

  if [ "$has_overrides" != "true" ]; then
    return
  fi

  for env_name in $(compgen -e); do
    case "$env_name" in
      CONFIG__*)
        env_path="${env_name#CONFIG__}"
        ;;
      config__*)
        env_path="${env_name#config__}"
        ;;
      *)
        continue
        ;;
    esac

    if [ -z "$env_path" ]; then
      continue
    fi

    env_value="${!env_name}"
    path_json="$(jq -cn --arg path "$env_path" '$path | split("__") | map(select(length > 0))')"
    tmp_config_file="${CONFIG_FILE}.tmp"

    jq \
      --argjson path "$path_json" \
      --arg raw "$env_value" \
      'setpath($path; ($raw | try fromjson catch $raw))' \
      "$CONFIG_FILE" > "$tmp_config_file"

    mv "$tmp_config_file" "$CONFIG_FILE"
  done
}

cat <<EOF > "$CONFIG_FILE"
{
   "log": {
      "level": "info",
      "job_level": "info"
   },
   "runner": {
      "file": "$RUNNER_FILE",
      "capacity": 1,
      "envs": {},
      "env_file": ".env",
      "timeout": "3h",
      "shutdown_timeout": "3h",
      "insecure": false,
      "fetch_timeout": "5s",
      "fetch_interval": "2s",
      "report_interval": "1s",
      "labels": [
         "ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest",
         "ubuntu-24.04:docker://docker.gitea.com/runner-images:ubuntu-24.04",
         "docker:docker://data.forgejo.org/oci/node:lts"
      ]
   },
   "cache": {
      "enabled": true,
      "port": 0,
      "dir": "",
      "external_server": "",
      "secret": "",
      "secret_url": "",
      "host": "",
      "proxy_port": 0,
      "actions_cache_url_override": ""
   },
   "container": {
      "network": "",
      "enable_ipv6": false,
      "privileged": false,
      "options": null,
      "workdir_parent": null,
      "valid_volumes": [],
      "docker_host": "-",
      "force_pull": false,
      "force_rebuild": false
   },
   "host": {
      "workdir_parent": null
   },
   "server": {
      "connections": null
   }
}
EOF

apply_config_env_overrides

if [ ! -f "$RUNNER_FILE" ]; then
  /bin/forgejo-runner -c "$CONFIG_FILE" register \
    --no-interactive \
    --instance "$FORGEJO_INSTANCE_URL" \
    --token "$FORGEJO_RUNNER_REGISTRATION_TOKEN" \
    --name "$FORGEJO_RUNNER_NAME"
fi

exec /bin/forgejo-runner -c "$CONFIG_FILE" daemon
