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

# Basic image
ARG GO_VERSION=1.14.3
ARG GO_BASE_IMAGE=
ARG GO_DOCKER_NAME=golang
ARG GO_DOCKER_TAG=${GO_VERSION}${GO_BASE_IMAGE:+-}${GO_BASE_IMAGE}
FROM ${GO_DOCKER_NAME}:${GO_DOCKER_TAG} as base

# Install packages
FROM base as builder

ARG GOLANGCI_LINT_VERSION=v1.27.0
ARG GOLANGCI_LINT_URL="https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh"

RUN \
    if command -v apt-get 2>&1 >/dev/null; then \
        apt-get update && \
        apt-get install --yes --no-install-recommends --no-upgrade \
            gcc \
            git \
            curl \
            && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*; \
    elif command -v apk 2>&1 >/dev/null; then \
        apk update --no-cache && \
        apk add --no-cache \
            gcc \
            git \
            curl \
            libc-dev; \
    fi && \
    echo "Downloading, building and installing golangci-lint..." && \
    (curl -sSfL "$GOLANGCI_LINT_URL" | sh -s -- -b "$(go env GOPATH)/bin" "$GOLANGCI_LINT_VERSION") && \
    echo "Downloading, building and installing errcheck..." && \
    go get -u github.com/kisielk/errcheck && \
    echo "Downloading, building and installing goimports..." && \
    go get -u golang.org/x/tools/cmd/goimports && \
    echo "Downloading, building and installing golint..." && \
    go get -u golang.org/x/lint/golint && \
    echo "Downloading, building and installing revive..." && \
    go get -u github.com/mgechev/revive && \
    echo "Downloading, building and installing richgo..." && \
    go get -u github.com/kyoh86/richgo && \
    echo "Downloading, building and installing go-junit-report..." && \
    go get -u github.com/jstemmer/go-junit-report && \
    echo "Downloading, building and installing gocover-cobertura..." && \
    go get -u github.com/t-yuki/gocover-cobertura && \
    echo "Downloading, building and installing godoc..." && \
    go get -u golang.org/x/tools/cmd/godoc && \
    echo "Downloading, building and installing mockgen..." && \
    go get -u github.com/golang/mock/mockgen

# Build image
FROM base

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Build-time metadata as defined at http://label-schema.org
LABEL \
    maintainer="tymoteusz.blazejczyk@tymonx.com" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="tymonx/docker-go" \
    org.label-schema.description="A Docker image with preinstalled tools for formatting, linting, testing and documenting Go projects" \
    org.label-schema.usage="https://gitlab.com/tymonx/docker-go/README.md" \
    org.label-schema.url="https://gitlab.com/tymonx/docker-go" \
    org.label-schema.vcs-url="https://gitlab.com/tymonx/docker-go" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vendor="tymonx" \
    org.label-schema.version=$VERSION \
    org.label-schema.docker.cmd=\
"docker run --rm --user $(id -u):$(id -g) --volume $(pwd):$(pwd) --workdir $(pwd) --entrypoint /bin/bash registry.gitlab.com/tymonx/docker-go"

ENV \
    GOCACHE=/tmp/.cache/go-build \
    GOLANGCI_LINT_CACHE=/tmp/.cache/golangci-lint

RUN \
    if command -v apt-get 2>&1 >/dev/null; then \
        apt-get update && \
        apt-get install --yes --no-install-recommends --no-upgrade \
            bc \
            gcc \
            git \
            curl \
            wget \
            colordiff \
            bsdmainutils \
            && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*; \
    elif command -v apk 2>&1 >/dev/null; then \
        apk update --no-cache && \
        apk add --no-cache \
            gcc \
            git \
            curl \
            wget \
            bash \
            colordiff \
            util-linux \
            libc-dev; \
    fi

COPY --from=builder /go/bin /usr/local/go/bin/
COPY scripts /usr/local/bin/
COPY configs /root/