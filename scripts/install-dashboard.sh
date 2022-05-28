#!/bin/bash

installDashboard ()
{
  header "install kubernetes-dashboard"

  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

  cat <<EOF | helm install --namespace kubernetes-dashboard --create-namespace -f - kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
extraArgs:
  - --enable-skip-login
  - --enable-insecure-login
  - --disable-settings-authorizer=true
  #- --system-banner="This is ${CLUSTER_NAME}"

protocolHttp: true

service:
  externalPort: 8888

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: lets-encrypt-http-issuer
  paths:
    - /
  hosts:
    - dashboard.${CLUSTER_DOMAIN}
  tls:
    - hosts:
        - dashboard.${CLUSTER_DOMAIN}
      secretName: dashboard-cert

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
  
  footer
}
