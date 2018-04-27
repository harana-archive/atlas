#!/usr/bin/env bash
set -euo pipefail

export DOCKER_TAG=$(echo "${BUILDKITE_BRANCH}-${BUILDKITE_COMMIT:0:8}" | tr '[:upper:]' '[:lower:]' | sed 's/\//-/g')

cat <<YAML
steps:

  - name: ":docker: Docker Image"
    command: ""
    plugins:
      ecr#v1.1.3:
        login: true
      
      docker-compose:
        build:
          - atlas
        image-name: ${DOCKER_TAG}
        image-repository: ${DOCKER_IMAGE_REPO}

YAML
