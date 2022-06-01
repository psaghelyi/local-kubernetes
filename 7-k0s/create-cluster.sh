#!/bin/bash

# Installation variables
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=${CLUSTER_IP}.nip.io
CLUSTER_NAME=k0s
HOST_IP=$(dig +short host.docker.internal)

source scripts/helpers.sh
source scripts/install-metal-lb.sh
source scripts/install-cert-manager.sh
source scripts/install-ingress.sh
source scripts/install-dashboard.sh

header "cleanup previous run"
docker rm -f ${CLUSTER_NAME} ${CLUSTER_NAME}-worker1 ${CLUSTER_NAME}-worker2
footer

header "create cluster (master node)"
docker run -d --name ${CLUSTER_NAME} --hostname ${CLUSTER_NAME} --privileged -v /var/lib/k0s -p 6443:6443 -p 8080:80 -p 8443:443 docker.io/k0sproject/k0s:latest

sleep 10s
until docker exec ${CLUSTER_NAME} kubectl wait --for=condition=Ready nodes --all --timeout=120s
do
    echo 'waiting for master node...'
    sleep 5s
done
footer

header "update kube config"
docker exec ${CLUSTER_NAME} cat /var/lib/k0s/pki/admin.conf > k0s.config
export KUBECONFIG=k0s.config
footer

# cert-manager needs some help to deploy
kubectl taint nodes ${CLUSTER_NAME} node-role.kubernetes.io/master-
installCertManager

LB_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CLUSTER_NAME})
installMetalLB

installIngress

installDashboard
