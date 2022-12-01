FROM ubuntu:20.04 AS builder

RUN apt-get update && apt-get install -y curl

WORKDIR /artifacts

# download gitleaks 8.15.1
RUN curl -L https://github.com/zricethezav/gitleaks/releases/download/v8.15.1/gitleaks_8.15.1_linux_x64.tar.gz --output gitleaks_8.15.1_linux_x64.tar.gz
RUN tar xzvf gitleaks_8.15.1_linux_x64.tar.gz
## verify gitleaks hash
RUN if [ $(sha256sum gitleaks | awk '{print $1}') = "8d44ada684d65a247d6358cea7cfbf4f8c8595b7b1b3f5d6a8416ef754c402d7" ] ; then echo good ; else exit 1 ; fi

FROM alpine:3.16

WORKDIR /artifacts

COPY --from=builder ["/artifacts/gitleaks", "./gitleaks"]
