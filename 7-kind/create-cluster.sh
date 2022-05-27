#!/bin/bash

# Installation variables
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=127.0.0.1.nip.io
HOST_IP=$(dig +short host.docker.internal)

source scripts/helpers.sh
source scripts/install-cert-manager.sh
source scripts/install-dashboard.sh

kind delete clusters --all

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

kind create cluster --name k8s-playground --config kind-config.yaml

rm kind-config.yaml

kubectl config use-context kind-k8s-playground


installCertManager

# ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

installDashboard


