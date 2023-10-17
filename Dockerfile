# syntax=docker/dockerfile:1

# Download gitleaks
FROM --platform=$BUILDPLATFORM alpine:3.18@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978 AS gitleaks

WORKDIR /artifacts

ARG TARGETPLATFORM

RUN --mount=type=bind,source=checksums.txt,target=checksums.txt <<EOT
  set -e

  url=
  case "$TARGETPLATFORM" in
    "linux/amd64")
      url=https://github.com/zricethezav/gitleaks/releases/download/v8.15.1/gitleaks_8.15.1_linux_x64.tar.gz
      ;;
    "linux/arm64")
      url=https://github.com/zricethezav/gitleaks/releases/download/v8.15.1/gitleaks_8.15.1_linux_arm64.tar.gz
      ;;
    *)
      printf "ERROR: %s" "invalid architecture"
      exit 1
  esac

  archive="$(basename ${url})"

  wget -q -O "${archive}" "${url}"

  grep "${archive}" checksums.txt | sha256sum -c -

  tar xzvf "${archive}"
EOT

# Download lynis
FROM --platform=$BUILDPLATFORM alpine:3.18@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978 AS lynis

WORKDIR /artifacts

ARG TARGETPLATFORM

RUN --mount=type=bind,source=checksums.txt,target=checksums.txt <<EOT
  set -e

  url="https://github.com/CISOfy/lynis/archive/refs/tags/3.0.8.tar.gz"
  archive="lynis_$(basename ${url})"

  wget -q -O "${archive}" "${url}"

  grep "${archive}" checksums.txt | sha256sum -c -

  tar xzvf "${archive}"
EOT

# Download chkrootkit
FROM --platform=$BUILDPLATFORM alpine:3.18@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978 AS chkrootkit

WORKDIR /artifacts

ARG TARGETPLATFORM

RUN --mount=type=bind,source=checksums.txt,target=checksums.txt <<EOT
  set -e

  url="ftp://ftp.chkrootkit.org/pub/seg/pac/chkrootkit-0.57.tar.gz"
  archive="$(basename ${url})"

  wget -q -O "${archive}" "${url}"

  grep "${archive}" checksums.txt | sha256sum -c -

  tar xzvf "${archive}"
EOT

FROM alpine:3.18@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

WORKDIR /opt

RUN apk upgrade --no-cache --quiet
RUN apk add --no-cache clamav
RUN apk add --no-cache yara --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk add --no-cache openssh

COPY --from=gitleaks ["/artifacts/gitleaks", "./gitleaks"]
COPY --from=lynis ["/artifacts/lynis-3.0.8", "./lynis"]
COPY --from=chkrootkit ["/artifacts/chkrootkit-0.57/chkrootkit", "./chkrootkit"]

RUN <<EOT
  set -e

  # Install chkrootkit
  ln -s /opt/chkrootkit /bin/chkrootkit

  # Install gitleaks
  ln -s /opt/gitleaks /bin/gitleaks

  # Install lynis
  ln -s /opt/lynis /usr/local/lynis
  ln -s /opt/lynis/lynis /bin/lynis
EOT
