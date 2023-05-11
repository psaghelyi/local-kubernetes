#!/bin/bash

source scripts/helpers.sh
source scripts/install-cert-manager.sh
source scripts/install-ingress.sh
source scripts/install-dashboard.sh
source scripts/install-monitoring.sh


# Installation variables
HOST_IP=$(getHostIp)
CLUSTER_IP=127.0.0.1
CLUSTER_NAME=cluster-1
CLUSTER_DOMAIN=${CLUSTER_IP}.nip.io
API_PORT=6443
HTTP_PORT=8080
HTTPS_PORT=8443
GRAFANA_PORT=3000
INFLUXDB_PORT=8086
SERVERS=1
AGENTS=2
INSTALL_CERTMANAGER=Yes
INSTALL_INGRESS=Yes
INSTALL_DASHBOARD=Yes
INSTALL_MONITORING=No
INSTALL_KUBEAPPS=No
INSTALL_LINKERD=No
READ_VALUE=


read_value "Cluster Name" "${CLUSTER_NAME}"
CLUSTER_NAME=${READ_VALUE}
read_value "Cluster Domain" "${CLUSTER_DOMAIN}"
CLUSTER_DOMAIN=${READ_VALUE}
read_value "Servers (Masters)" "${SERVERS}"
SERVERS=${READ_VALUE}
read_value "Agents (Workers)" "${AGENTS}"
AGENTS=${READ_VALUE}
read_value "API Port" "${API_PORT}"
API_PORT=${READ_VALUE}
read_value "LoadBalancer HTTP Port" "${HTTP_PORT}"
HTTP_PORT=${READ_VALUE}
read_value "LoadBalancer HTTPS Port" "${HTTPS_PORT}"
HTTPS_PORT=${READ_VALUE}



header "cleanup previous run"
k3d cluster delete -a
footer

header "create cluster"
cat <<EOF  > tmp-${CLUSTER_NAME}.yaml
  apiVersion: k3d.io/v1alpha4
  kind: Simple
  metadata:
    name: ${CLUSTER_NAME}
  servers: ${SERVERS}
  agents: ${AGENTS}
  kubeAPI:
    hostIP: "0.0.0.0"
    hostPort: "${API_PORT}" # kubernetes api port 6443:6443
  image: rancher/k3s:latest
  volumes:
    - volume: $(pwd)/.storage:/var/lib/rancher/k3s/storage
      nodeFilters:
        - all
  ports:
    - port: 0.0.0.0:${HTTP_PORT}:80 # http port host:container
      nodeFilters:
        - loadbalancer
    - port: 0.0.0.0:${HTTPS_PORT}:443 # https port host:container
      nodeFilters:
        - loadbalancer
    - port: 0.0.0.0:${GRAFANA_PORT}:3000
      nodeFilters:
        - loadbalancer
    - port: 0.0.0.0:${INFLUXDB_PORT}:8086
      nodeFilters:
        - loadbalancer
  env:
    - envVar: secret=token
      nodeFilters:
        - all
  registries:
    create:
      name: "registry.${CLUSTER_IP}.nip.io"
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

K3D_FIX_DNS=1 k3d cluster create --config tmp-${CLUSTER_NAME}.yaml
rm tmp-${CLUSTER_NAME}.yaml

kubectl wait --for=condition=Ready nodes --all --timeout=120s
kubectl cluster-info
footer

#read_value "Install CertManager? ${yes_no}" "${INSTALL_CERTMANAGER}"
#if [ $(isSelected ${READ_VALUE}) = 1 ];
#then
    installCertManager
#fi

#read_value "Install Ingress? (NGINX) ${yes_no}" "${INSTALL_INGRESS}"
#if [ $(isSelected ${READ_VALUE}) = 1 ];
#then
    installIngress
#fi

#read_value "Install Dashboard? ${yes_no}" "${INSTALL_DASHBOARD}"
#if [ $(isSelected ${READ_VALUE}) = 1 ];
#then
    installDashboard
#fi

read_value "Install the monitoring stack? (telegraf, influxDB, grafana) ${yes_no}" "${INSTALL_MONITORING}"
if [ $(isSelected ${READ_VALUE}) = 1 ];
then
    installMonitoring
fi





