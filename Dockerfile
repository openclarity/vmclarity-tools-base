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

# download and extract clamav binaries
RUN curl -L https://www.clamav.net/downloads/production/clamav-0.104.1.tar.gz --output clamav-0.104.1.tar.gz && \
    tar xzf clamav-0.104.1.tar.gz && \
    cd clamav-0.104.1 && \
    ./configure && \
    make && \
    make install

# update virus definitions
RUN freshclam

FROM alpine:3.16

WORKDIR /artifacts

COPY --from=builder ["/artifacts/gitleaks", "./gitleaks"]
COPY --from=builder ["/usr/local/bin/clamscan", "./clam"]
COPY --from=builder ["/usr/local/bin/freshclam", "./clam"]

