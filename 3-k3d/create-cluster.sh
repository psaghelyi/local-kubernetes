#!/bin/bash

source scripts/helpers.sh
source scripts/install-cert-manager.sh
source scripts/install-ingress.sh
source scripts/install-dashboard.sh


# Installation variables
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=127.0.0.1.nip.io
HOST_IP=$(dig +short host.docker.internal)
API_PORT=6443
HTTP_PORT=8080
HTTPS_PORT=8443
CLUSTER_NAME=cluster-1
SERVERS=1
AGENTS=2


installCluster ()
{
  header "Deleting Previous Cluster"
  k3d cluster delete ${CLUSTER_NAME}
  footer

  header "Creating K3D cluster"
#https://github.com/rancher/k3d/blob/main/tests/assets/config_test_simple.yaml
  cat <<EOF  > tmp-k3d-${CLUSTER_NAME}.yaml
apiVersion: k3d.io/v1alpha3
kind: Simple
name: ${CLUSTER_NAME}
servers: ${SERVERS} 
agents: ${AGENTS}
kubeAPI:
  hostIP: "0.0.0.0"
  hostPort: "${API_PORT}" # kubernetes api port 6443:6443
image: rancher/k3s:latest
#image: rancher/k3s:v1.22.6-k3s1
#volumes:
#  - volume: $(pwd)/k3dvol:/tmp/k3dvol # volume in host:container
#    nodeFilters:
#      - all
ports:
  - port: 0.0.0.0:${HTTP_PORT}:80 # http port host:container
    nodeFilters:
      - loadbalancer
  - port: 0.0.0.0:${HTTPS_PORT}:443 # https port host:container
    nodeFilters:
      - loadbalancer
env:
  - envVar: secret=token
    nodeFilters:
      - all
registries:
  create:
    name: "k3d-registry.${HOST_IP}.nip.io"
    host: "0.0.0.0"
    hostPort: "5000"
options:
  k3d:
    wait: true
    timeout: "60s" # avoid an start/stop cicle when start fails
    disableLoadbalancer: false
    disableImageVolume: false
  k3s:
    extraArgs:
      - arg: --tls-san=127.0.0.1  # Add additional hostname or IP as a Subject Alternative Name in the TLS cert
        nodeFilters:
          - server:*
      - arg: --disable=traefik
        nodeFilters:
          - server:*
  kubeconfig:
    updateDefaultKubeconfig: true # update kubeconfig when cluster starts
    switchCurrentContext: true # change this cluster context when cluster starts
EOF

  K3D_FIX_DNS=1 k3d cluster create --config tmp-k3d-${CLUSTER_NAME}.yaml
  rm tmp-k3d-${CLUSTER_NAME}.yaml

  kubectl config use-context k3d-${CLUSTER_NAME}
  kubectl cluster-info
  footer

  header "Provisioning Persistent Volume"
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: k3d-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/k3dvol"
EOF

  kubectl describe pv k3d-pv
  footer
}



installCluster

installCertManager

installIngress

installDashboard
