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

DOCKER_ARGUMENTS=$@

mkdir -p /tmp/go/

docker run \
    --rm \
    --tty \
    --interactive \
    --user "$(id -u):$(id -g)" \
    --volume "$(pwd):$(pwd)" \
    --volume "/tmp/:/tmp/" \
    --volume "/tmp/go/:/go/" \
    --volume "/etc/group:/etc/group:ro" \
    --volume "/etc/passwd:/etc/passwd:ro" \
    --workdir "$(pwd)" \
    --entrypoint /bin/bash \
    "registry.gitlab.com/tymonx/docker-go:1.14.3" \
    ${DOCKER_ARGUMENTS:+-c "$DOCKER_ARGUMENTS"}
