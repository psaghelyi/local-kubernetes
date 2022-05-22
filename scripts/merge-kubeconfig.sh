#!/bin/bash

cp ~/.kube/config ~/.kube/config.bak && KUBECONFIG=~/.kube/config:$1 kubectl config view --flatten > /tmp/config && mv /tmp/config ~/.kube/config
