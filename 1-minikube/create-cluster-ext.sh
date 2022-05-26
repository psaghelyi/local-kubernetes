#!/bin/bash

# Installation variables
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=127.0.0.1.nip.io
HOST_IP=$(dig +short host.docker.internal)

source scripts/helpers.sh
source scripts/install-cert-manager.sh
source scripts/install-ingress.sh
source scripts/install-dashboard.sh


minikube delete --all

minikube start --cpus 4 --driver='docker' --nodes 2

minikube update-context


installCertManager

installIngress

installDashboard

# start load balancer
minikube tunnel

# if minikube tunnel was broken, then use the following workaround:
# kubectl port-forward -n ingress service/ingress-nginx-ingress-controller 8443:443
