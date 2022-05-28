#!/bin/bash

###################################
######## Minimal Minikube #########
###################################

source scripts/helpers.sh

header "cleanup previous run"
minikube delete --all
footer

header "create cluster"
minikube start --cpus 4 --addons dashboard,metrics-server --driver='docker'
footer

header "update kube config"
minikube update-context
footer

header "create proxy for dashboard"
minikube dashboard
footer

# minikube addons list
