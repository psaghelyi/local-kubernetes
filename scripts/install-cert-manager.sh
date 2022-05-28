#!/bin/bash

installCertManager()
{
  header "install cert-manager"

  helm repo add jetstack https://charts.jetstack.io

  helm repo update

  helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.7.1 \
    --set installCRDs=true
    #--set webhook.securePort=10260

  footer

  cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Secret
    metadata:
      name: ca-key-pair
      namespace: cert-manager
    data:
      tls.crt: $(cat .certs/${CLUSTER_DOMAIN}.cer | base64 -w0)
      tls.key: $(cat .certs/${CLUSTER_DOMAIN}-key | base64 -w0)
EOF

  footer
  
  cat <<EOF | kubectl apply -f -
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: lets-encrypt-http-issuer
      namespace: cert-manager
    spec:
      ca:
        secretName: ca-key-pair
EOF

  footer
}

