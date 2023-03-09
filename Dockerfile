FROM ubuntu:20.04 AS builder

RUN apt-get update && apt-get install -y curl

WORKDIR /artifacts

# copy checksums file
COPY checksums.txt .

# download gitleaks 8.15.1
RUN curl -L https://github.com/zricethezav/gitleaks/releases/download/v8.15.1/gitleaks_8.15.1_linux_x64.tar.gz --output gitleaks_8.15.1_linux_x64.tar.gz

# validate checksums
RUN sha256sum -c checksums.txt

# install gitleaks
RUN tar xzvf gitleaks_8.15.1_linux_x64.tar.gz

FROM alpine:3.16

RUN apk upgrade
RUN apk add clamav
RUN freshclam

WORKDIR /artifacts

COPY --from=builder ["/artifacts/gitleaks", "./gitleaks"]
