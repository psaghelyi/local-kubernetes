#!/bin/bash


# bold text 
bold=$(tput bold)
normal=$(tput sgr0)
yes_no="(${bold}Y${normal}es/${bold}N${normal}o)"


header()
{
    echo
    echo
    echo ${bold}${1}${normal}
    echo "-------------------------------------"
}


footer()
{
    echo "-------------------------------------"
}


# $1 text to show - $2 default value
read_value ()
{
    read -p "${1} [${bold}${2}${normal}]: " READ_VALUE
    if [ "${READ_VALUE}" = "" ]
    then
        READ_VALUE=$2
    fi
}


isSelected()
{
  if [ "${1}" = "Yes" ] || [ "${1}" = "yes" ] || [ "${1}" = "Y" ]  || [ "${1}" = "y" ];
  then
    echo 1
  else
    echo 0
  fi
}


# Check if exist docker, k3d and kubectl
checkDependencies ()
{
    # Check Docker
    if ! type docker > /dev/null; then
        echo "Docker could not be found. Installing it ..."
        curl -L -o ./install-docker.sh "https://get.docker.com"
        chmod +x ./install-docker.sh
        ./install-docker.sh
        sudo usermod -aG docker $USER
    fi

    # Check K3D
    if ! type k3d > /dev/null; then
        echo "K3D could not be found. Installing it ..."
        curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
        # Install k3d autocompletion for bash
        echo "source <(k3d completion bash)" >> ~/.bashrc
    fi

    # Check Kubectl
    if ! type kubectl > /dev/null; then
        echo "Kubectl could not be found. Installing it ..."
        curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
        kubectl version --client
    fi

    # Check Helm
    if ! type helm > /dev/null; then
        echo "Helm could not be found. Installing it ..."
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
        chmod +x ./get_helm.sh
        ./get_helm.sh

        # Add default repos
        helm repo add stable https://charts.helm.sh/stable
        # Update helm
        helm repo update
    fi
}

getHostIp()
{
    docker run --rm busybox /bin/nslookup host.docker.internal | awk '/^Address: / { print $2 }'
}

getCatalog()
{
    curl -X GET http://registry.127.0.0.1.nip.io:5000/v2/_catalog
}