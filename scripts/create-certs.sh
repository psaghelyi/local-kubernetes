#!/bin/bash

createCerts()
{
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
              -keyout .certs/"${CLUSTER_DOMAIN}"-key -out .certs/"${CLUSTER_DOMAIN}".cer \
              -subj "/CN=*.${CLUSTER_DOMAIN}" \
              -addext "subjectAltName=DNS:${CLUSTER_DOMAIN},DNS:*.${CLUSTER_DOMAIN},IP:${CLUSTER_IP}"
}
