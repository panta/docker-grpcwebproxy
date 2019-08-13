ARG ALPINE_VERSION=latest
ARG GOLANG_VERSION=1.12.5
ARG GRPCWEB_VERSION=v0.11.0

FROM golang:${GOLANG_VERSION}-alpine as builder
MAINTAINER Marco Pantaleoni <marco.pantaleoni@gmail.com>

ENV LANG=C.UTF-8

# Install base packages
RUN apk -U add --no-cache \
    ca-certificates wget curl git \
  && rm -rf /var/cache/apk/*

RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

RUN mkdir -p "$(go env GOPATH)"/src/github.com/improbable-eng/grpc-web
RUN git clone https://github.com/improbable-eng/grpc-web.git "$(go env GOPATH)"/src/github.com/improbable-eng/grpc-web
RUN cd "$(go env GOPATH)"/src/github.com/improbable-eng/grpc-web && \
	git checkout ${GRPCWEB_VERSION} && \
	dep ensure && \
	go install ./go/grpcwebproxy && \
	cp "$(go env GOPATH)"/bin/grpcwebproxy /


FROM alpine:${ALPINE_VERSION}
MAINTAINER Marco Pantaleoni <marco.pantaleoni@gmail.com>

# env variables

RUN apk -U add ca-certificates bash \
	curl openssl \
  && rm -rf /var/cache/apk/*

WORKDIR /
COPY --from=builder /grpcwebproxy /usr/bin/

EXPOSE 8080/tcp
EXPOSE 8443/tcp

CMD ["/usr/bin/grpcwebproxy"]
