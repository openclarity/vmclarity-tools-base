# syntax=docker/dockerfile:1

# Download gitleaks
FROM --platform=$BUILDPLATFORM alpine:3.19@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48 AS gitleaks

WORKDIR /artifacts

ARG TARGETPLATFORM

RUN <<EOT
  set -e

  version=8.18.0
  url=
  checksum=
  case "$TARGETPLATFORM" in
    "linux/amd64")
      url=https://github.com/zricethezav/gitleaks/releases/download/v${version}/gitleaks_${version}_linux_x64.tar.gz
      checksum=6e19050a3ee0688265ed3be4c46a0362487d20456ecd547e8c7328eaed3980cb
      ;;
    "linux/arm64")
      url=https://github.com/zricethezav/gitleaks/releases/download/v${version}/gitleaks_${version}_linux_arm64.tar.gz
      checksum=c19c2af7087e1c2bd502f85ae92e6477133fc43ce17f5ea09f63ebda6e3da0be
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
FROM --platform=$BUILDPLATFORM alpine:3.19@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48 AS lynis

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
FROM --platform=$BUILDPLATFORM alpine:3.19@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48 AS chkrootkit

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

FROM alpine:3.19@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48

WORKDIR /opt

RUN apk upgrade --no-cache --quiet
RUN apk add --no-cache clamav
RUN apk add --no-cache yara --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
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
