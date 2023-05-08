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
    --version v1.11.0 \
    --set installCRDs=true
    #--set webhook.securePort=10260

  footer

  if [[ "${OSTYPE}" == "darwin"* ]]; then
    BASE64="base64"
  else
    BASE64="base64 -w0"
  fi
  cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Secret
    metadata:
      name: ca-key-pair
      namespace: cert-manager
    data:
      tls.crt: $(cat .certs/${CLUSTER_DOMAIN}.cer | ${BASE64} )
      tls.key: $(cat .certs/${CLUSTER_DOMAIN}.key | ${BASE64} )
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

