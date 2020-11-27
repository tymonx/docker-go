#!/usr/bin/env sh
#
# Copyright 2020 Tymoteusz Blazejczyk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Exit on error
set -e

# Get Go path to store downloaded Go package sources
if [ -z "${GOPATH:-}" ]; then
    if command -v go 2>&1 >/dev/null; then
        GOPATH="$(go env GOPATH)"
    fi
fi

# Create a temporary directory for all downloaded Go modules. To have
# the correct file mode permissions with proper user and group,
# this directory must be created before running the docker run command
# with the --volume argument. Otherwise, docker will create directory
# for us with directory properties from container. Mostly of time it is
# unwanted root:root
mkdir -p "${GOPATH:-/tmp/go}"

# Run Docker image as container. Mount current working directory to container.
# This will allow all commands from Docker to have access to files and
# directories under current working directory, mostly of time it is a project
# workspace. All created files and directories will have proper mode file
# permissions from current user who invokes this script
docker run \
    --rm \
    --tty \
    --interactive \
    --user "$(id -u):$(id -g)" \
    --volume "$(pwd):$(pwd)" \
    --volume "/tmp/:/tmp/" \
    --volume "${GOPATH:-/tmp/go}:/go/" \
    --volume "/etc/group:/etc/group:ro" \
    --volume "/etc/passwd:/etc/passwd:ro" \
    --workdir "$(pwd)" \
    --publish "${GODOC_PORT:-6060}:6060" \
    --entrypoint /bin/bash \
    "registry.gitlab.com/tymonx/docker-go:v1.15.5" \
    ${@:+-c "$*"}
