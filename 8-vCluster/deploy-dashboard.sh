#!/bin/bash

# Installation variables
CLUSTER_NAME=vcluster
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=${CLUSTER_NAME}.${CLUSTER_IP}.nip.io

source scripts/helpers.sh
source scripts/install-cert-manager.sh
source scripts/install-dashboard.sh


export KUBECONFIG=./kubeconfig.yaml

installCertManager

installDashboard
