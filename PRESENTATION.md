---
title: Working with Local Kubernetes
---

# Working with Local Kubernetes
_Hands-on Session_

---

# How It's Made

* **Container Management** (CRI -> container runtime)
* **Network Management** (CNI -> iptables, dns)
* **Volume Management** (CSI -> mounts)
* **Configuration Storge** (etcd, sql)

---

# What It's Made

* **kube-apiserver**
* **kube-scheduler**
* **kube-controll-manager**
* **kubelet**
* **kube-proxy**

---

<img data-src="assets/kubernetes-structure.png" class="stretch"/>

---

# Minimal Valuable Cluster
_Functionalities for Convenience_

* **Nodes (server/agent/control-plane)**
* **Dashboard & Metrics**
* **Ingress**
* **Load Balancer / Tunnel**
* (Image Registry)
* (Cert Manager)

---

### ⚠️ Docker Knowledge Required ⚠️
_Training module expects understanding of Docker and containers_

---

# 1 - Minikube
_[https://minikube.sigs.k8s.io/](https://minikube.sigs.k8s.io/)_

* **Developed by Google**
* **CNCF certified**
* **Multi-cluster** - `minikube start -p <name>`
* **LoadBalancer** - `minikube tunnel`
* **Persistent Volumes**
* **Ingress**
* **Container runtime** - Docker,containerd,CRI-O
* **Networking** - Calico,Flannel

---

# 💻 Demo 💻 #

---

# 2 - MicroK8s
_[https://microk8s.io/](https://microk8s.io/)_

* **Developed by Canonical**
* **CNCF certified**
* **Multi-cluster**
* **Persistent Volumes**
* **Ingress**
* **Container runtime** - containerd,kata
* **Networking** - Calico

---

# 💻 Demo 💻 #

---

# 3 - k3s / k3d by Rancher
__[https://k3s.io/](https://k3s.io/)__ - __[https://k3d.io/](https://k3d.io/)__

* **Developed by Rancher**
* **CNCF certified**
* **Multi-cluster**
* **LoadBalancer**
* **Persistent Volumes**
* **Ingress**
* **Container runtime** - CRI-O
* **Networking** - Flannel,Canal

---

# 💻 Demo 💻 #

---

# 4 - k0s
_[https://k0sproject.io/](https://k0sproject.io/)_

* **Developed by Team Lens**
* **CNCF certified**
* **Multi-cluster**
* **Persistent Volumes**
* **Ingress**
* **Container runtime** - containerd
* **Networking** - Kube-Router,Calico

---

# 5 - Docker Desktop

---

# 6 - Rancher Desktop

---

# 7 - KIND

---


# 8 - vCluster

---
