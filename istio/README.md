# Deploy Istio
## Table of contents
  - [Prerequisites](#prerequisites)
## Prerequisites
1. Kubernetes cluster or Kubernetes local development with [kind](../local-development/kind/README.md)   
2.[Kubernetes client kubectl](https://kubernetes.io/docs/tasks/tools/)
## Check Kubernetes cluster
```shell
kubectl get node
NAME                  STATUS     ROLES                  AGE   VERSION
istio-control-plane   NotReady   control-plane,master   14s   v1.23.0
```
## Install istio CLI specific version Eg. 1.13.1
```shell
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.13.1 TARGET_ARCH=x86_64 sh -
cd istio-1.13.1
export PATH=$PWD/bin:$PATH
```
## Check istio CLI version
```shell
istioctl version
```
The output looks similar to the following:
```shell
no running Istio pods in "istio-system"
1.13.1
```
## Check compatability with target cluster
```shell
istioctl x prechec
```
The output looks similar to the following:
```
✔ No issues found when checking the cluster. Istio is safe to install or upgrade!
  To get started, check out https://istio.io/latest/docs/setup/getting-started/
```
