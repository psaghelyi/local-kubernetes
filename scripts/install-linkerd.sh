#!/bin/bash

installLinkerd()
{
  header "Setup Linkerd - CRDs"
  linkerd install --crds | kubectl apply -f -
  
  header "Setup Linkerd - Control Pane"
  linkerd install | kubectl apply -f -

  header "Setup Linkerd - Viz"
  linkerd viz install --set grafana.externalUrl=http://localhost:3000 | kubectl apply -f -
  #kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd2/main/grafana/authzpolicy-grafana.yaml

  header "Inject proxy to monitoring ns"
  kubectl get deploy -n monitoring -o yaml | linkerd inject - | kubectl apply -f -

  cat <<EOF | kubectl apply -f -
apiVersion: policy.linkerd.io/v1alpha1
kind: AuthorizationPolicy
metadata:
  namespace: linkerd-viz
  name: grafana
spec:
  targetRef:
    group: policy.linkerd.io
    kind: Server
    name: prometheus-admin
  requiredAuthenticationRefs:
    - kind: ServiceAccount
      name: grafana
      namespace: monitoring
EOF

  header "Setup Linkerd - Jaeger"
  linkerd jaeger install | kubectl apply -f - 
  
  footer
}

