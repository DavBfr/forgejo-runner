# Forgejo Runner Docker Image

Docker image for running a Forgejo Actions runner with Docker socket access.

This image wraps the upstream `forgejo-runner` binary and generates a JSON configuration file at container startup. Configuration can be customized through environment variables, including nested config overrides using `config__...` keys.

## Features

- Based on the upstream Forgejo runner binary
- Registers the runner automatically on first start
- Stores runner state in `/data`
- Uses the Docker socket to launch container-based jobs
- Supports nested JSON config overrides via environment variables

## Quick Start

```yaml
services:
  runner:
    image: davbfr/forgejo-runner:12
    container_name: forgejo-runner
    environment:
      - FORGEJO_INSTANCE_URL=https://forgejo.example.com
      - FORGEJO_RUNNER_REGISTRATION_TOKEN=your-registration-token
      - FORGEJO_RUNNER_NAME=docker-runner-01
      - config__runner__capacity=2
      - config__runner__timeout=2h
    volumes:
      - ./data:/data
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
```

Start the runner:

```bash
docker compose up -d
```

## Required Environment Variables

- `FORGEJO_INSTANCE_URL`: URL of your Forgejo instance
- `FORGEJO_RUNNER_REGISTRATION_TOKEN`: runner registration token from Forgejo
- `FORGEJO_RUNNER_NAME`: name shown in the Forgejo UI

## Persistent Data

Mount `/data` to persist:

- generated config at `/data/config.json`
- runner registration state at `/data/.runner`

Without a persistent `/data` volume, the container will register as a new runner every time it starts.

## Docker Socket

Mount the host Docker socket:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

This is required for Docker-based Forgejo Actions jobs.

## Config Overrides

The container builds `/data/config.json` on startup, then applies any environment variables that start with `config__` or `CONFIG__`.

Format:

```text
config__<key0>__<key1>__<key2>=<value>
```

Example:

```text
config__runner__capacity=2
config__cache__enabled=false
config__runner__labels=["ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest"]
config__runner__envs__HTTP_PROXY=http://proxy.internal:3128
```

These become JSON updates like:

```json
{
  "runner": {
    "capacity": 2,
    "labels": [
      "ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest"
    ],
    "envs": {
      "HTTP_PROXY": "http://proxy.internal:3128"
    }
  },
  "cache": {
    "enabled": false
  }
}
```

Value parsing rules:

- valid JSON is parsed as JSON
- any other value is stored as a string

Examples:

- `true` becomes a boolean
- `2` becomes a number
- `["a","b"]` becomes an array
- `hello` stays a string

## Default Behavior

On startup the container:

1. Writes a default `/data/config.json`
2. Applies all `config__...` overrides
3. Registers the runner if `/data/.runner` does not exist
4. Starts `forgejo-runner daemon`

## Notes

- The registration step only runs once when `/data/.runner` is missing.
- If you want to re-register the runner, remove `/data/.runner` and start the container again.
- Runner labels should be configured through the JSON config using `config__runner__labels=[...]`.

## Example: Custom Labels

```yaml
services:
  runner:
    image: davbfr/forgejo-runner:12
    environment:
      - FORGEJO_INSTANCE_URL=https://forgejo.example.com
      - FORGEJO_RUNNER_REGISTRATION_TOKEN=your-registration-token
      - FORGEJO_RUNNER_NAME=docker-runner-01
      - config__runner__labels=["ubuntu-24.04:docker://docker.gitea.com/runner-images:ubuntu-24.04","docker:docker://data.forgejo.org/oci/node:lts"]
    volumes:
      - ./data:/data
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
```
