# Prerequisites:
#   dep ensure --vendor-only
#   bblfsh-sdk release

#==============================
# Stage 1: Native Driver Build
#==============================
FROM python:3.6-alpine as native

ADD native /native
WORKDIR /native

# build native driver
RUN pip3 install -U --prefix=./.local ./python_package


#================================
# Stage 1.1: Native Driver Tests
#================================
FROM native as native_test
# run native driver tests
RUN cd ./python_package/test && PYTHONPATH=../../.local:$PYTHONPATH python3 -m unittest discover


#=================================
# Stage 2: Go Driver Server Build
#=================================
FROM golang:1.10-alpine as driver

ENV DRIVER_REPO=github.com/bblfsh/python-driver
ENV DRIVER_REPO_PATH=/go/src/$DRIVER_REPO

ADD vendor $DRIVER_REPO_PATH/vendor
ADD driver $DRIVER_REPO_PATH/driver

WORKDIR $DRIVER_REPO_PATH/

# build server binary
RUN go build -o /tmp/driver ./driver/main.go
# build tests
RUN go test -c -o /tmp/fixtures.test ./driver/fixtures/

#=======================
# Stage 3: Driver Build
#=======================
FROM python:3.6-alpine

RUN apk add python2


LABEL maintainer="source{d}" \
      bblfsh.language="python"

WORKDIR /opt/driver

# copy static files from driver source directory
ADD ./native/sh/native.sh ./bin/native


# copy build artifacts for native driver
COPY --from=native /native/.local ./bin/.local


# copy driver server binary
COPY --from=driver /tmp/driver ./bin/

# copy tests binary
COPY --from=driver /tmp/fixtures.test ./bin/
# move stuff to make tests work
RUN ln -s /opt/driver ../build
VOLUME /opt/fixtures

# copy driver manifest and static files
ADD .manifest.release.toml ./etc/manifest.toml

ENTRYPOINT ["/opt/driver/bin/driver"]