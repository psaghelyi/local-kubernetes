microk8s uninstall

microk8s install

microk8s enable dns dashboard registry ingress

microk8s config > microk8s.config

set KUBECONFIG=microk8s.config

multipass info microk8s-vm | wsl grep IPv4 | wsl awk '{ print $2 }'

microk8s dashboard-proxy
