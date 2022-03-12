# Deploy Istio
## Table of contents
  - [Prerequisites](#prerequisites)
## Prerequisites
1. Kubernetes cluster or Kubernetes local development with [kind](../local-development/kind/README.md)
## Step 1 - Check Kubernetes cluster
```shell
kubectl get node
NAME                  STATUS     ROLES                  AGE   VERSION
istio-control-plane   NotReady   control-plane,master   14s   v1.23.0
```