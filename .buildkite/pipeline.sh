#!/usr/bin/env bash
set -euo pipefail

export DOCKER_TAG=$(echo "${BUILDKITE_BRANCH}-${BUILDKITE_COMMIT:0:8}" | tr '[:upper:]' '[:lower:]' | sed 's/\//-/g')

cat <<YAML
steps:

  - name: ":docker: Build Image"
    command: ".buildkite/dummy.sh"
    plugins:
      docker-compose:
        build:
          - atlas
        image-name: ${DOCKER_TAG}
        image-repository: ${DOCKER_IMAGE_REPO}

YAML
