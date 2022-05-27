#!/bin/bash

docker rm -f k0s-worker1 k0s-worker2

# Create Worker Nodes
token=$(docker exec -t -i k0s k0s token create --role=worker)

docker run -d --name k0s-worker1 --hostname k0s-worker1 --privileged -v /var/lib/k0s docker.io/k0sproject/k0s:latest k0s worker $token
docker run -d --name k0s-worker2 --hostname k0s-worker2 --privileged -v /var/lib/k0s docker.io/k0sproject/k0s:latest k0s worker $token

sleep 10s
until docker exec k0s kubectl wait --for=condition=Ready nodes --all --timeout=120s
do
    echo 'waiting for worker node...'
    sleep 5s
done

docker exec k0s kubectl get nodes
