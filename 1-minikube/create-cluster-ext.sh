#!/bin/bash

###################################
######## Extended Minikube ########
###################################

# Installation variables
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=${CLUSTER_IP}.nip.io
HOST_IP=$(dig +short host.docker.internal)

source scripts/helpers.sh
source scripts/install-cert-manager.sh
source scripts/install-ingress.sh
source scripts/install-dashboard.sh

header "cleanup previous run"
minikube delete --all
footer

header "create cluster"
minikube start --cpus 4 --driver='docker' --nodes 3
footer

header "update kube config"
minikube update-context
footer

installCertManager

installIngress

installDashboard

header "start the load balancer"
minikube tunnel
footer

# if minikube tunnel was broken, then use the following workaround:
# kubectl port-forward -n ingress service/ingress-nginx-ingress-controller 8443:443
