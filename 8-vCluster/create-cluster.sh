#!/bin/bash

# installation:
# curl -s -L "https://github.com/loft-sh/vcluster/releases/latest" | sed -nE 's!.*"([^"]*vcluster-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o vcluster && chmod +x vcluster;
# sudo mv vcluster /usr/local/bin;

# Installation variables
CLUSTER_NAME=vcluster
CLUSTER_IP=127.0.0.1
CLUSTER_DOMAIN=${CLUSTER_NAME}.${CLUSTER_IP}.nip.io

source scripts/helpers.sh
source scripts/install-cert-manager.sh
source scripts/install-dashboard.sh


header "cleanup previous run"
vcluster delete ${CLUSTER_NAME} -n host-namespace-1 --delete-namespace
kubectl wait namespace/host-namespace-1 --for=delete --timeout=120s
footer


header "create cluster"
cat <<EOF  > vcluster-values.yaml
syncer:
  extraArgs:
  - --tls-san=${CLUSTER_DOMAIN}
EOF

vcluster create ${CLUSTER_NAME} -n host-namespace-1 -f vcluster-values.yaml --distro k3s
rm vcluster-values.yaml
footer

# special ingress for virtual cluster kube-api
cat <<EOF | kubectl apply -f -
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/backend-protocol: HTTPS
      nginx.ingress.kubernetes.io/ssl-passthrough: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    name: vcluster-ingress
    namespace: host-namespace-1
  spec:
    rules:
    - host: ${CLUSTER_DOMAIN}
      http:
        paths:
        - backend:
            service:
              name: ${CLUSTER_NAME}
              port: 
                number: 443
          path: /
          pathType: ImplementationSpecific
EOF

# connect to the virtual cluster through the vcluster ingress
vcluster connect ${CLUSTER_NAME} -n host-namespace-1 --server=https://${CLUSTER_DOMAIN}

# switch context to the virtual cluster
export KUBECONFIG=./kubeconfig.yaml

installCertManager

installDashboard
