# How to create Kubernetest local development
## Table of contents
  - [Prerequisites](#prerequisites)
## Prerequisites
1. A [Git](https://git-scm.com/downloads) client, to clone the `kube-prometheus-stack` repository.

## Step 1 - Creaet cluster
```shell
CLUSER_VERSION=1.22.5
cat <<EOF | kind create cluster --name test-cluster --image kindest/node:v${CLUSER_VERSION} --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF
```