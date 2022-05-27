---
title: Working with Local Kubernetes
---

# Working with Local Kubernetes
_Hands-on Session_

---

# How It's Made
_Cloud Native Computing Foundation_

* **Container Management** (CRI -> container runtime)
* **Network Management** (CNI -> iptables, dns)
* **Volume Management** (CSI -> mounts)
* **Configuration Storge** (etcd, sql)

---

# What It's Made

* **kube-apiserver**
* **kube-scheduler**
* **kube-controller-manager**
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
* **Multi-node-cluster** - `minikube start -p <name>`
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
* **Multi-node-cluster** - `microk8s add-node`, then start new VM
* **Persistent Volumes**
* **Ingress** - NGINX
* **Container runtime** - containerd,kata
* **Networking** - Calico
* **Based on [Multipass](https://multipass.run/docs)**

---

# 💻 Demo 💻 #

---

# 3 - K3D
__[https://k3d.io/](https://k3d.io/)__

* **Developed by Rancher**
* **CNCF certified**
* **Multi-node-cluster** - automatic
* **LoadBalancer** - dedicated
* **Persistent Volumes** - automatic
* **Ingress** - Traefik by default
* **Container runtime** - CRI-O
* **Networking** - Flannel,Canal

---

# 💻 Demo 💻 #

---

# 4 - k0s
_[https://k0sproject.io/](https://k0sproject.io/)_

* **Developed by Team Lens**
* **CNCF certified**
* **Multi-node-cluster**
* **Persistent Volumes**
* **Ingress**
* **Container runtime** - containerd
* **Networking** - Kube-Router,Calico
* **One single binary** - statically linked, no OS-level dependencies

---

# 💻 Demo 💻 #

---

# 5 - Docker Desktop

* **Developed by Docker Inc.**
* **CNCF certified**
* **Single-node-cluster** - k8s
* **Persistent Volumes**
* **Ingress**
* **Container runtime** - dockerd
* **Networking** - vpnkit

---

# 💻 Demo 💻 #

---

# 6 - Rancher Desktop

* **Developed by Rancher Inc.**
* **CNCF certified**
* **Single-node-cluster** - k3s
* **Persistent Volumes**
* **Ingress** - Traefik by default
* **Container runtime** - containerd,dockerd(moby)
* **Networking** - Flannel,Calico,Canal

---

# 💻 Demo 💻 #

---

# 7 - KIND

* **Developed by Google**
* **CNCF certified**
* **Multi-node-cluster**
* **Ingress** - needs special config
* **Container runtime** - dockerd
* **Networking** - kindnet ([ptp](https://www.cni.dev/plugins/current/main/ptp/) plugin for CNI)

---

# 💻 Demo 💻 #

---

# 8 - vCluster
_[https://www.vcluster.com/](https://www.vcluster.com/)_

* **Developed by Loft Labs**
* **CNCF certified**


---

# 💻 Demo 💻 #

---

# ❓ Q&A ❓ #

---
