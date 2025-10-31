#!/usr/bin/env bash

# Helper that grabs binary from a docker image, scans it with govulncheck, and produces an OpenVEX document.
# Usage:
#  ./scan.sh quay.io/strimzi/kafka:0.45.0-kafka-3.9.0 /opt/kafka-exporter/kafka_exporter pkg:golang/github.com/danielqsj/kafka_exporter@1.8.0
#  ./scan.sh public.ecr.aws/eks/amazon-k8s-cni-init:v1.20.4-eksbuild.1 init/bandwidth "pkg:golang/github.com/containernetworking/plugins"
# Arguments:
#  $1: Docker image name
#  $2: Path to binary inside the docker image
#  $3: PURL of the binary being scanned

set -eux

IMAGE_NAME=$1
SRC_PATH=$2
PURL=$3
AUTHOR="agologan@users.noreply.github.com"
NAME=$(basename $SRC_PATH)

docker create --name dummy $IMAGE_NAME
docker cp dummy:$SRC_PATH $NAME
docker rm -f dummy

~/go/bin/govulncheck -mode binary -format openvex $NAME > scan.openvex.json
rm $NAME

jq ".statements[].products[0].\"@id\" = \"$PURL\"" scan.openvex.json | sponge scan.openvex.json
jq ".author = \"$AUTHOR\"" scan.openvex.json | sponge scan.openvex.json
