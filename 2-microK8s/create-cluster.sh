#!/bin/bash

microk8s enable dns dashboard registry ingress

microk8s kubectl get pods -A


