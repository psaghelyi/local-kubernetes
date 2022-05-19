#!/bin/bash

# Installation variables
CLUSTER_DOMAIN=127.0.0.1.nip.io

installIngress ()
{
  header "Installing Ingress"

  # Create Namespace
  kubectl create namespace ingress

  # Install ingress with tls enabled providing certificates stored in namespace
  helm repo add bitnami https://charts.bitnami.com/bitnami
  cat <<EOF | helm install --namespace ingress -f - ingress bitnami/nginx-ingress-controller
EOF
  footer
  sleep 5
  header "LoadBalancer info:"
  kubectl -n ingress get svc | egrep -e NAME -e LoadBalancer
  footer
}

installDashboard ()
{
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

  cat <<EOF | helm install --namespace kubernetes-dashboard --create-namespace -f - kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
extraArgs:
  - --enable-skip-login
  - --enable-insecure-login
  - --disable-settings-authorizer=true

protocolHttp: true

service:
  externalPort: 80

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  paths:
    - /
  hosts:
    - dashboard.${CLUSTER_DOMAIN}

metricsScraper:
  enabled: true
EOF

  kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:kubernetes-dashboard
}

installIngress

installDashboard

