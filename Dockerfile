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

# the runtime stage contains all the elements needed to run the master and the analysis tools:
FROM ubuntu:17.10 as runtime

# install runtime deps
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /go/bin/qmstr-wrapper /usr/local/bin/qmstr-wrapper
COPY --from=builder /go/bin/qmstr-cli /usr/local/bin/qmstr-cli

RUN mkdir -p /QMSTR/bin
RUN ln -s /usr/local/bin/qmstr-wrapper /QMSTR/bin/gcc

ENV QMSTR_HOME /QMSTR

# release calc container, based on the runtime stage:
FROM runtime as demoCalc
RUN mkdir -p /calc
COPY build.inc /build.inc
COPY calc/build.sh /calc/build.sh
COPY calc/qmstr.tmpl /calc/qmstr.tmpl
COPY calc/Calculator /calc/Calculator
WORKDIR /calc
CMD [ "/calc/build.sh" ]

# release curl container, based on the runtime stage:
FROM runtime as demoCurl
RUN mkdir -p /curl
COPY build.inc /build.inc
COPY curl/qmstr.tmpl /curl/qmstr.tmpl
COPY curl/build.sh /curl/build.sh
CMD [ "/curl/build.sh" ]
