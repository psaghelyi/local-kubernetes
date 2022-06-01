#!/bin/bash

# installation:
# curl -s -L "https://github.com/loft-sh/vcluster/releases/latest" | sed -nE 's!.*"([^"]*vcluster-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o vcluster && chmod +x vcluster;
# sudo mv vcluster /usr/local/bin;

# Installation variables
CLUSTER_NAME=vcluster

source scripts/helpers.sh

header "cleanup previous run"
vcluster delete ${CLUSTER_NAME} -n host-namespace-1 --delete-namespace
kubectl wait namespace/host-namespace-1 --for=delete --timeout=120s
footer


header "create cluster"
vcluster create ${CLUSTER_NAME} -n host-namespace-1 --distro k3s
footer


header "use ${CLUSTER_NAME}"
vcluster connect ${CLUSTER_NAME} -n host-namespace-1

