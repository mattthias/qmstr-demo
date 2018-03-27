# Create container that builds the software for calc demo case
FROM golang:1.9 as builder

# install build deps
RUN apt-get update && \
    apt-get install -y git protobuf-compiler && \
    rm -rf /var/lib/apt/lists/*

# install golang tools
RUN go get -u github.com/golang/protobuf/protoc-gen-go && \
    go get -u github.com/golang/dep/cmd/dep
RUN go get -d github.com/QMSTR/qmstr | true

RUN cd $GOPATH/src/github.com/QMSTR/qmstr && \
    dep ensure
RUN go generate github.com/QMSTR/qmstr/cmd/qmstr-wrapper 
RUN go install github.com/QMSTR/qmstr/cmd/qmstr-wrapper && \
    go install github.com/QMSTR/qmstr/cmd/qmstr-cli



# the runtime stage contains all the elements needed to run the master:
FROM ubuntu:17.10 as runtime

# install runtime deps 
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /go/bin
COPY --from=builder /go/bin/qmstr-wrapper /go/bin/qmstr-wrapper
COPY --from=builder /go/bin/qmstr-cli /go/bin/qmstr-cli

RUN mkdir -p /QMSTR/bin
RUN ln -s /go/bin/qmstr-wrapper /QMSTR/bin/gcc

ENV QMSTR_HOME /QMSTR

COPY build.inc /build.inc
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]




FROM runtime as dev

ENV GOPATH /go
ENV PATH ${GOPATH}/bin:/usr/lib/go-1.9/bin:$PATH

# install golang 1.9
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:gophers/archive && \
    apt-get update && \
    apt-get install -y curl golang-1.9-go autoconf git libio-captureoutput-perl python python-pip protobuf-compiler

EXPOSE 2345

# install go deps
RUN go get -u github.com/golang/protobuf/protoc-gen-go && \
    go get github.com/dgraph-io/dgo && \
    go get -u github.com/derekparker/delve/cmd/dlv && \
    go get github.com/spf13/pflag

# The $GOROOT/src directory can be passed in as a volume, to allow for testing local changes.
VOLUME /go/src

VOLUME /qmstr-demo/demos

ENV QMSTR_DEV ""
ENV QMSTR_DEMO_DEV true
COPY dev-entrypoint.sh /dev-entrypoint.sh
RUN chmod +x /dev-entrypoint.sh
ENTRYPOINT [ "/dev-entrypoint.sh" ]
