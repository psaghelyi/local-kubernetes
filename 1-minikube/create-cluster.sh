#!/bin/bash

minikube delete --all

minikube start --cpus 4 --addons dashboard,metrics-server,ingress --driver='docker' --nodes 3

# minikube addons list

#minikube addons enable ingress
#minikube addons enable registry
#minikube addons enable dashboard

#minikube addons enable metallb
#minikube addons configure metallb

kubectl apply -f ingress.yaml

minikube tunnel
