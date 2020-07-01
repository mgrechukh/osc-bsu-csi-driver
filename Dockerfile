# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.12.7-stretch as builder
WORKDIR /go/src/github.com/kubernetes-sigs/aws-ebs-csi-driver
# Cache go modules
COPY go.mod .
COPY go.sum .
RUN go mod download

ARG DEBUG_IMAGE="disable"

RUN apt-get -y update && \
    if [ ${DEBUG_IMAGE} == "enable" ]; then \
        apt-get -y install gdb jq; \
        echo "add-auto-load-safe-path /usr/local/go/src/runtime/runtime-gdb.py" >> /root/.gdbinit; \
    fi

ADD . .
RUN make

FROM debian:stretch
RUN apt install -yqq ca-certificates e2fsprogs xfsprogs util-linux
COPY --from=builder /go/src/github.com/kubernetes-sigs/aws-ebs-csi-driver/bin/aws-ebs-csi-driver /bin/aws-ebs-csi-driver
ENTRYPOINT ["/bin/aws-ebs-csi-driver"]
