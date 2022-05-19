#!/bin/bash

docker run -d --name k0s --hostname k0s --privileged -v /var/lib/k0s -p 6443:6443 docker.io/k0sproject/k0s:latest

token=$(docker exec -t -i k0s k0s token create --role=worker)

docker run -d --name k0s-worker1 --hostname k0s-worker1 --privileged -v /var/lib/k0s docker.io/k0sproject/k0s:latest k0s worker $token

docker exec k0s kubectl get nodes

# grab kube-config
docker exec k0s cat /var/lib/k0s/pki/admin.conf
