#!/bin/bash

# Installation variables
CLUSTER_DOMAIN=127.0.0.1.nip.io
HOST_IP=192.168.1.220
API_PORT=6443
HTTP_PORT=8080
HTTPS_PORT=8443
CLUSTER_NAME=cluster-1
READ_VALUE=
SERVERS=1
AGENTS=2
INSTALL_INGRESS=Yes
INSTALL_DASHBOARD=Yes

# bold text
bold=$(tput bold)
normal=$(tput sgr0)
yes_no="(${bold}Y${normal}es/${bold}N${normal}o)"


# $1 text to show - $2 default value
read_value ()
{
    read -p "${1} [${bold}${2}${normal}]: " READ_VALUE
    if [ "${READ_VALUE}" = "" ]
    then
        READ_VALUE=$2
    fi
}

# Check if exist docker, k3d and kubectl
checkDependencies ()
{
    # Check Docker
    if ! type docker > /dev/null; then
        echo "Docker could not be found. Installing it ..."
        curl -L -o ./install-docker.sh "https://get.docker.com"
        chmod +x ./install-docker.sh
        ./install-docker.sh
        sudo usermod -aG docker $USER
    fi

    # Check K3D
    if ! type k3d > /dev/null; then
        echo "K3D could not be found. Installing it ..."
        curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
        # Install k3d autocompletion for bash
        echo "source <(k3d completion bash)" >> ~/.bashrc
    fi

    # Check Kubectl
    if ! type kubectl > /dev/null; then
        echo "Kubectl could not be found. Installing it ..."
        curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
        kubectl version --client
    fi

    # Check Helm
    if ! type helm > /dev/null; then
        echo "Helm could not be found. Installing it ..."
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
        chmod +x ./get_helm.sh
        ./get_helm.sh

        # Add default repos
        helm repo add stable https://charts.helm.sh/stable
        # Update helm
        helm repo update
    fi
}

header()
{
    echo
    echo
    echo ${bold}${1}${normal}
    echo
    echo "-------------------------------------"
}

footer()
{
    echo "-------------------------------------"
}


configValues ()
{
  read_value "Cluster Name" "${CLUSTER_NAME}"
  CLUSTER_NAME=${READ_VALUE}
  read_value "Cluster Domain" "${CLUSTER_DOMAIN}"
  CLUSTER_DOMAIN=${READ_VALUE}
  read_value "Servers (Masters)" "${SERVERS}"
  SERVERS=${READ_VALUE}
  read_value "Agents (Workers)" "${AGENTS}"
  AGENTS=${READ_VALUE}
  read_value "LoadBalancer HTTP Port" "${HTTP_PORT}"
  HTTP_PORT=${READ_VALUE}
  read_value "LoadBalancer HTTPS Port" "${HTTPS_PORT}"
  HTTPS_PORT=${READ_VALUE}
}


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
volumes:
  - volume: $(pwd)/k3dvol:/tmp/k3dvol # volume in host:container
    nodeFilters:
      - all
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

installCertManager()
{
    header "Creating Cert Manager"

    helm repo add jetstack https://charts.jetstack.io

    helm repo update

    helm install \
      cert-manager jetstack/cert-manager \
      --namespace cert-manager \
      --create-namespace \
      --version v1.7.1 \
      --set installCRDs=true
      #--set webhook.securePort=10260

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
}


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
  #kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml
}


installDashboard ()
{
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

  cat <<EOF | helm install --namespace kubernetes-dashboard --create-namespace -f - kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
extraArgs:
  #- --auto-generate-certificates
  - --enable-skip-login
  - --enable-insecure-login
  - --disable-settings-authorizer=true
  #- --system-banner="This is ${CLUSTER_NAME}"

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

# Global dashboard settings
settings:
  # Cluster name that appears in the browser window title if it is set
  clusterName: "${CLUSTER_NAME}"
  # Max number of items that can be displayed on each list page
  itemsPerPage: 25
  ## Number of seconds between every auto-refresh of logs
  # logsAutoRefreshTimeInterval: 5
  ## Number of seconds between every auto-refresh of every resource. Set 0 to disable
  resourceAutoRefreshTimeInterval: 5
  ## Hide all access denied warnings in the notification panel
  # disableAccessDeniedNotifications: false

metricsScraper:
  enabled: true
EOF

  kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:kubernetes-dashboard
}

isSelected()
{
  if [ "${1}" = "Yes" ] || [ "${1}" = "yes" ] || [ "${1}" = "Y" ]  || [ "${1}" = "y" ];
  then
    echo 1
  else
    echo 0
  fi
}

installAddons ()
{
  read_value "Install Ingress? (NGINX) ${yes_no}" "${INSTALL_INGRESS}"
  if [ $(isSelected ${READ_VALUE}) = 1 ];
  then
      installCertManager
      installIngress
  fi

  read_value "Install Kubernetes Dashbord? ${yes_no}" "${INSTALL_DASHBOARD}"
  if [ $(isSelected ${READ_VALUE}) = 1 ];
  then
      installDashboard
  fi
}

checkDependencies

configValues

installCluster

installAddons
