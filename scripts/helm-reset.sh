#!/bin/bash

# uninstall everything previously was installed with helm

helm ls -a --all-namespaces | awk 'NR > 1 { print  "-n "$2, $1}' | xargs -L1 helm delete
