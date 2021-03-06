FROM runtime as demobase

# install runtime deps 
RUN apt-get update
RUN apt-get install -y docker.io wget cmake libtool pkgconf libssl-dev

RUN mkdir -p /go/bin
COPY --from=qmstr/master_build /go/bin/qmstr /go/bin/qmstr
COPY --from=qmstr/master_build /go/bin/qmstr-wrapper /go/bin/qmstr-wrapper
COPY --from=qmstr/master_build /go/bin/qmstr-cli /go/bin/qmstr-cli

ENV GOPATH /go
ENV PATH ${GOPATH}/bin:/usr/lib/go-1.9/bin:$PATH

COPY --from=qmstr/master_build  $GOPATH/src/github.com/QMSTR/qmstr /qmstr

VOLUME /go/src

ENV QMSTR_ADDRESS "qmstr-demo-master:50051"

ADD build.inc ./build.inc

#ADD ./qmstr-master /qmstr-master

#RUN CALC DEMO
FROM demobase as democalc

ENTRYPOINT [ "/demos/calc/entrypoint.sh" ]

FROM demobase as democurl

ENTRYPOINT [ "/demos/curl/entrypoint.sh" ]