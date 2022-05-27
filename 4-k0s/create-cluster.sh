#!/bin/bash

# Installation variables
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=127.0.0.1.nip.io
HOST_IP=$(dig +short host.docker.internal)

source scripts/helpers.sh
source scripts/install-metal-lb.sh
source scripts/install-cert-manager.sh
source scripts/install-ingress.sh
source scripts/install-dashboard.sh

docker rm -f k0s

# Create Master Node
docker run -d --name k0s --hostname k0s --privileged -v /var/lib/k0s -p 6443:6443 -p 80:80 -p 443:443 docker.io/k0sproject/k0s:latest

sleep 10s
until docker exec k0s kubectl wait --for=condition=Ready nodes --all --timeout=120s
do
    echo 'waiting for master node...'
    sleep 5s
done

# grab kube-config
docker exec k0s cat /var/lib/k0s/pki/admin.conf > k0s.config
export KUBECONFIG=k0s.config

# CertManager
kubectl taint nodes k0s node-role.kubernetes.io/master-
installCertManager

installMetalLB

installIngress

installDashboard
