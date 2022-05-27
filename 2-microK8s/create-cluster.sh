#!/bin/bash

# Installation variables
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=127.0.0.1.nip.io
HOST_IP=$(dig +short host.docker.internal)
LB_IP=127.0.0.1


source scripts/helpers.sh
source scripts/install-cert-manager.sh
source scripts/install-metal-lb.sh
source scripts/install-ingress.sh
source scripts/install-dashboard.sh


microk8s config > ~/.kube-config
kubectl config use-context microk8s

installCertManager

installIngress

installDashboard

installMetalLB
