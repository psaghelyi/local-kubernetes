---
title: Working with Local Kubernetes
---

# Working with Local Kubernetes
_Hands-on Session_

---

# What Makes Kubernetes?

* **Container Management** (CRI -> container runtime)
* **Network Management** (CNI -> iptables, dns)
* **Volume Management** (CSI -> mounts)
* **Configuration Storge** (etcd, sql)

---

# How It Makes Kubernetes

* kube-apiserver
* kube-scheduler
* kube-controll-manager
* kubelet
* kube-proxy

---

# How does Kubernetes Look Like?



---

# Minimal Valuable Cluster
_Must-have Components for Convenience_

* High Avialibility (server/agent/control-pane)
* Dashboard & Metrics
* Ingress
* Load Balancer
* (Image Registry)
* (Cert Manager)

---

# What is high availability Kubernetes?

* There must be more than one worker node
* The Kubernetes API services must be running on more than one node
* The cluster state must be in a reliable datastore

---

### ⚠️ Docker Knowledge Required ⚠️
_Training module expects understanding of Docker and containers_

---

# 1 - Minikube
_[https://minikube.sigs.k8s.io/](https://minikube.sigs.k8s.io/)_

* Linux
    * **Docker** - container-based (preferred)
    * **KVM2** - VM-based (preferred)
    * **VirtualBox** - VM
    * **None** - bare-metal
    * **Podman** - container (experimental)
    * **SSH** - remote ssh

---

# 1 - Minikube
_[https://minikube.sigs.k8s.io/](https://minikube.sigs.k8s.io/)_

* macOS
    * **Docker** - VM + Container (preferred)
    * **Hyperkit** - VM
    * **VirtualBox** - VM
    * **Parallels** - VM
    * **VMware Fusion** - VM
    * **SSH** - remote ssh

---

# 1 - Minikube
_[https://minikube.sigs.k8s.io/](https://minikube.sigs.k8s.io/)_

* Windows
    * **Hyper-V** - VM (preferred)
    * **Docker** - WSL2 + Container (preferred)
    * **VirtualBox** - VM
    * **VMware Workstation** - VM
    * **SSH** - remote ssh

---

# 2 - MicroK8s
_[https://microk8s.io/](https://microk8s.io/)_



---

# 3 - k0s
_[https://k0sproject.io/](https://k0sproject.io/)_

---

# 4 - Docker Desktop

---

# 5 - Rancher Desktop

---

# 6 - KIND

---

# 7 - k3s / k3d by Rancher
__[https://k3s.io/](https://k3s.io/)__

__[https://k3d.io/](https://k3d.io/)__

---

# 8 - vCluster

---
