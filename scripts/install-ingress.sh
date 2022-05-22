#!/bin/bash

installIngress ()
{
  header "Installing Ingress"

  # Create Namespace
  kubectl create namespace ingress

  # Install ingress with tls enabled providing certificates stored in namespace
  helm repo add bitnami https://charts.bitnami.com/bitnami
  cat <<EOF | helm install --namespace ingress -f - ingress bitnami/nginx-ingress-controller
EOF

# comment the previous section and uncomment this for vanilla NGINX ingress:
#  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml

  footer
  sleep 5
  header "LoadBalancer info:"
  kubectl -n ingress get svc | egrep -e NAME -e LoadBalancer
  footer
}

