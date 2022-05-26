#!/bin/bash

###################################
######## Minimal Minikube #########
###################################

minikube delete --all

minikube start --cpus 4 --addons dashboard,metrics-server --driver='docker'

# minikube addons list

minikube update-context

minikube dashboard

