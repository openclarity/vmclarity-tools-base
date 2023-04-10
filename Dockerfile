FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y curl

WORKDIR /artifacts

# copy checksums file
COPY checksums.txt .

# download gitleaks 8.15.1
RUN curl -L https://github.com/zricethezav/gitleaks/releases/download/v8.15.1/gitleaks_8.15.1_linux_x64.tar.gz --output gitleaks_8.15.1_linux_x64.tar.gz

# download lynis 3.0.8
RUN curl -L https://github.com/CISOfy/lynis/archive/refs/tags/3.0.8.tar.gz --output lynis_3.0.8.tar.gz

# download chkrootkit 0.57
RUN curl ftp://ftp.chkrootkit.org/pub/seg/pac/chkrootkit-0.57.tar.gz --output chkrootkit-0.57.tar.gz

# validate checksums
RUN sha256sum -c checksums.txt

# install gitleaks
RUN tar xzvf gitleaks_8.15.1_linux_x64.tar.gz

# install lynis
RUN tar xzvf lynis_3.0.8.tar.gz

# install chkrootkit
RUN tar xzvf chkrootkit-0.57.tar.gz

FROM alpine:3.17

RUN apk upgrade
RUN apk add clamav

WORKDIR /artifacts

COPY --from=builder ["/artifacts/gitleaks", "./gitleaks"]

COPY --from=builder ["/artifacts/lynis-3.0.8", "./lynis"]

COPY --from=builder ["/artifacts/chkrootkit-0.57/chkrootkit", "./chkrootkit"]
