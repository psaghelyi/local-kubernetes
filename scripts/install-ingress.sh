#!/bin/bash

installIngress ()
{
  header "install NGINX ingress"

  # Create Namespace
  kubectl create namespace ingress

  # Install ingress with tls enabled providing certificates stored in namespace
  helm repo add bitnami https://charts.bitnami.com/bitnami
  cat <<EOF | helm install --namespace ingress -f - ingress bitnami/nginx-ingress-controller
extraArgs:
  enable-ssl-passthrough: "true"
EOF

  footer
}

