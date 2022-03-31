# Deploy rancher HA mode on RKE
## Table of contents
  - [Prerequisites](#prerequisites)
  - [Step 1 - Check Kubernetes cluster](#step-1---check-kubernetes-cluster)
## Prerequisites
1. Download RKE binary [Dowload](https://rancher.com/docs/rke/latest/en/installation/#download-the-rke-binary)
2. Prepare 3 VMs and install [Requirements](https://rancher.com/docs/rke/latest/en/os/)
## Step 1 - Genarate RKE cluster configuaration
```shell
rke config
```
## Step 2 - Deploying Kubernetes with RKE
```shell
rke up
```

## Step 2 - Test cluster
```shell
export KUBECONFIG=$(pwd)/kube_config_cluster.yml
```
Note : 
https://rancher.com/docs/rancher/v2.5/en/installation/resources/k8s-tutorials/ha-rke/
