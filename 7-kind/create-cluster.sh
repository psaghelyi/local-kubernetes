#!/bin/bash

kind delete clusters --all

cat > kind-config.yaml <<EOF
# three node (two workers) cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

kind create cluster --name k8s-playground --config kind-config.yaml

rm kind-config.yaml
