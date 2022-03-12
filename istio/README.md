# Deploy Istio
## Table of contents
  - [Prerequisites](#prerequisites)
## Prerequisites
1. Kubernetes cluster or Kubernetes local development with [kind](../local-development/kind/README.md)   
2.[Kubernetes client kubectl](https://kubernetes.io/docs/tasks/tools/)
## Step 1 - Check Kubernetes cluster
```shell
kubectl get node
NAME                  STATUS     ROLES                  AGE   VERSION
istio-control-plane   NotReady   control-plane,master   14s   v1.23.0
```
## Step 2 - Install istio CLI specific version Eg. 1.13.1
```shell
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.13.1 TARGET_ARCH=x86_64 sh -
cd istio-1.13.1
export PATH=$PWD/bin:$PATH
```
## Step 3 - Check istio CLI version
```shell
istioctl version
```
The output looks similar to the following:
```shell
no running Istio pods in "istio-system"
1.13.1
```
## Step 4 - Check compatability with target cluster
```shell
istioctl x precheck
```
The output looks similar to the following:
```shell
✔ No issues found when checking the cluster. Istio is safe to install or upgrade!
  To get started, check out https://istio.io/latest/docs/setup/getting-started/
```
## Step 5 - Check Available istio profile
```shell
istioctl profile list
```
The output looks similar to the following:
```shell
    default
    demo
    empty
    external
    minimal
    openshift
    preview
    remote
```
Notes:[Istio profile](https://istio.io/latest/docs/setup/additional-setup/config-profiles)
## Install istio with default profile *This profile is recommended for production
```shell
istioctl install --set profile=default
```
The output looks similar to the following:
```shell
This will install the Istio 1.13.1 default profile with ["Istio core" "Istiod" "Ingress gateways"] components into the cluster. Proceed? (y/N) y
✔ Istio core installed
✔ Istiod installed
✔ Ingress gateways installed
✔ Installation complete
Making this installation the default for injection and validation.

Thank you for installing Istio 1.13.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/pzWZpAvMVBecaQ9h9
```