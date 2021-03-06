#!/bin/bash

# installation
# snap install microk8s --classic

# Installation variables
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=${CLUSTER_IP}.nip.io
CLUSTER_NAME=microk8s
HOST_IP=$(dig +short host.docker.internal)
LB_IP=127.0.0.1


source scripts/helpers.sh
source scripts/install-cert-manager.sh
source scripts/install-metal-lb.sh
source scripts/install-ingress.sh
source scripts/install-dashboard.sh


microk8s config > ~/.kube/config
kubectl config use-context microk8s

installCertManager

installIngress

installDashboard

installMetalLB
