# syntax=docker/dockerfile:1@sha256:ac85f380a63b13dfcefa89046420e1781752bab202122f8f50032edf31be0021

# Download gitleaks
FROM --platform=$BUILDPLATFORM alpine:3.20@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5 AS gitleaks

WORKDIR /artifacts

ARG TARGETPLATFORM

RUN <<EOT
  set -e

  version=8.18.2
  url=
  checksum=
  case "$TARGETPLATFORM" in
    "linux/amd64")
      url=https://github.com/zricethezav/gitleaks/releases/download/v${version}/gitleaks_${version}_linux_x64.tar.gz
      checksum=6298c9235dfc9278c14b28afd9b7fa4e6f4a289cb1974bd27949fc1e9122bdee
      ;;
    "linux/arm64")
      url=https://github.com/zricethezav/gitleaks/releases/download/v${version}/gitleaks_${version}_linux_arm64.tar.gz
      checksum=4df25683f95b9e1dbb8cc71dac74d10067b8aba221e7f991e01cafa05bcbd030
      ;;
    *)
      printf "ERROR: %s" "invalid architecture"
      exit 1
  esac

  archive="$(basename ${url})"

  wget -q -O "${archive}" "${url}"

  printf "%s %s" "${checksum}" "${archive}" | sha256sum -c -

  tar xzvf "${archive}"
EOT

# Download lynis
FROM --platform=$BUILDPLATFORM alpine:3.20@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5 AS lynis

WORKDIR /artifacts

ARG TARGETPLATFORM

RUN <<EOT
  set -e

  version=3.0.9
  url="https://github.com/CISOfy/lynis/archive/refs/tags/${version}.tar.gz"
  checksum=520eb76aee5d350c2a7265414bae302077cd70ed5a0aaf61dec9e43a968b1727

  archive="lynis_$(basename ${url})"

  wget -q -O "${archive}" "${url}"

  printf "%s %s" "${checksum}" "${archive}" | sha256sum -c -

  mkdir -p lynis
  tar xzvf "${archive}" -C lynis --strip-components 1
EOT

# Download chkrootkit
FROM --platform=$BUILDPLATFORM alpine:3.20@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5 AS chkrootkit

WORKDIR /artifacts

ARG TARGETPLATFORM

RUN <<EOT
  set -e

  version=0.58b
  url="ftp://ftp.chkrootkit.org/pub/seg/pac/chkrootkit-${version}.tar.gz"
  checksum=de110f07f37b1b5caff2e90cc6172dd8

  archive="$(basename ${url})"

  wget -q -O "${archive}" "${url}"

  printf "%s %s" "${checksum}" "${archive}" | md5sum -c -

  tar xzvf "${archive}" --strip-components 1
EOT

FROM alpine:3.20@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5

WORKDIR /opt

RUN apk upgrade --no-cache --quiet
RUN apk add --no-cache clamav=1.2.2-r0
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community yara=4.5.0-r0
RUN apk add --no-cache openssh
RUN apk add --no-cache git  # required by gitleaks
RUN apk add --no-cache grep # required by lynis

COPY --from=gitleaks ["/artifacts/gitleaks", "./gitleaks"]
COPY --from=lynis ["/artifacts/lynis", "./lynis"]
COPY --from=chkrootkit ["/artifacts/chkrootkit", "./chkrootkit"]

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
