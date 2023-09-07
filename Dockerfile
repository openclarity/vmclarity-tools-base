FROM --platform=$BUILDPLATFORM ubuntu:20.04 AS builder

RUN apt-get update && apt-get install -y curl

WORKDIR /artifacts

# copy checksums file
COPY checksums.txt .

ARG TARGETPLATFORM

# download gitleaks 8.15.1
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; \
    then \
      curl -sSfL https://github.com/zricethezav/gitleaks/releases/download/v8.15.1/gitleaks_8.15.1_linux_x64.tar.gz \
        --output gitleaks_8.15.1_linux_x64.tar.gz ; \
    fi
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; \
    then \
      curl -sSfL https://github.com/zricethezav/gitleaks/releases/download/v8.15.1/gitleaks_8.15.1_linux_arm64.tar.gz \
        --output gitleaks_8.15.1_linux_arm64.tar.gz; \
    fi

# download lynis 3.0.8
RUN curl -sSfL https://github.com/CISOfy/lynis/archive/refs/tags/3.0.8.tar.gz --output lynis_3.0.8.tar.gz

# download chkrootkit 0.57
RUN curl -sSf ftp://ftp.chkrootkit.org/pub/seg/pac/chkrootkit-0.57.tar.gz --output chkrootkit-0.57.tar.gz

# validate checksums
RUN sha256sum -c checksums.txt --ignore-missing

# install gitleaks
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ] ; then tar xzvf gitleaks_8.15.1_linux_x64.tar.gz ; fi
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ] ; then tar xzvf gitleaks_8.15.1_linux_arm64.tar.gz ; fi

# install lynis
RUN tar xzvf lynis_3.0.8.tar.gz

# install chkrootkit
RUN tar xzvf chkrootkit-0.57.tar.gz

FROM alpine:3.18

RUN apk upgrade
RUN apk add clamav
RUN apk add --update yara --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk add openssh

WORKDIR /artifacts

COPY --from=builder ["/artifacts/gitleaks", "./gitleaks"]

COPY --from=builder ["/artifacts/lynis-3.0.8", "./lynis"]

COPY --from=builder ["/artifacts/chkrootkit-0.57/chkrootkit", "./chkrootkit"]
