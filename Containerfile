# UBI-ification of acme-dns
# Mostly I'm just using a different target base image
# Tried building with the ubi9 go-toolset image, but is icky
#FROM registry.access.redhat.com/ubi9/go-toolset:1.20.12-3 AS builder
FROM golang AS builder
LABEL maintainer="danhawker <github.com/danhawker>"

ENV GOPATH /tmp/buildcache
RUN git clone https://github.com/danhawker/acme-dns /tmp/acme-dns
#COPY ./* /tmp/acme-dns
WORKDIR /tmp/acme-dns
RUN CGO_ENABLED=1 go build

# Use UBI Micro
# UBI Micro doesn't have CA truststore by default, may need to add later
FROM registry.access.redhat.com/ubi9/ubi-micro:latest

RUN mkdir -p /etc/acme-dns /var/lib/acme-dns /opt/acme-dns
WORKDIR /opt/acme-dns
COPY --from=builder /tmp/acme-dns/acme-dns .

VOLUME ["/etc/acme-dns", "/var/lib/acme-dns"]
ENTRYPOINT ["./acme-dns"]
EXPOSE 5353 8080 8443
EXPOSE 5353/udp
