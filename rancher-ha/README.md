# Deploy rancher HA mode on RKE
## Table of contents
  - [Prerequisites](#prerequisites)
  - [Step 1 - Check Kubernetes cluster](#step-1---check-kubernetes-cluster)
## Prerequisites
1. Kubernetes cluster or Kubernetes local development with [kind](../local-development/kind/README.md) with ingress-nginx.
2. Kubernetes client [kubectl](https://kubernetes.io/docs/tasks/tools/)
3. [Curl](https://curl.se/download.html), for testing the examples (backend applications).
## Step 1 - Check Kubernetes cluster
```shell
kubectl get node
NAME                  STATUS     ROLES                  AGE   VERSION
istio-control-plane   Ready      control-plane,master   14s   v1.23.0