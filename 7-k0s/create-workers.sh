#!/bin/bash

CLUSTER_NAME=k0s

source scripts/helpers.sh

docker rm -f ${CLUSTER_NAME}-worker1 ${CLUSTER_NAME}-worker2

header "Create Worker Nodes"
token=$(docker exec -t -i ${CLUSTER_NAME} k0s token create --role=worker)

docker run -d --name ${CLUSTER_NAME}-worker1 --hostname ${CLUSTER_NAME}-worker1 --privileged -v /var/lib/k0s docker.io/k0sproject/k0s:latest k0s worker $token
docker run -d --name ${CLUSTER_NAME}-worker2 --hostname ${CLUSTER_NAME}-worker2 --privileged -v /var/lib/k0s docker.io/k0sproject/k0s:latest k0s worker $token

sleep 10s
docker exec ${CLUSTER_NAME} kubectl wait --for=condition=Ready nodes --all --timeout=120s
footer

docker exec ${CLUSTER_NAME} kubectl get nodes
