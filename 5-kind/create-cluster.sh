#!/bin/bash

# Installation variables
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=${CLUSTER_IP}.nip.io
CLUSTER_NAME=k8s-playground
HOST_IP=$(dig +short host.docker.internal)

source scripts/helpers.sh
source scripts/install-cert-manager.sh
source scripts/install-dashboard.sh

header "cleanup previous run"
kind delete clusters --all
footer

header "create cluster"
cat > kind-config.yaml <<EOF
# three node (two workers) cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
  - containerPort: 443
    hostPort: 8443
- role: worker
- role: worker
EOF

kind create cluster --name ${CLUSTER_NAME} --config kind-config.yaml
rm kind-config.yaml
footer

header "update kube config"
kubectl config use-context kind-${CLUSTER_NAME}
footer

installCertManager

header "install NGINX ingress"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
footer


installDashboard
