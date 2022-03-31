# Deploy rancher HA mode on RKE
## Table of contents
  - [Prerequisites](#prerequisites)
  - [Step 1 - Check Kubernetes cluster](#step-1---check-kubernetes-cluster)
## Prerequisites
1. Download RKE binary [Dowload](https://rancher.com/docs/rke/latest/en/installation/#download-the-rke-binary)
2. Prepare 3 VMs and install [Requirements](https://rancher.com/docs/rke/latest/en/os/)
3. helm

## Step 0 - Prepare 3 node for RKE
```
#Install docker
sudo apt-get update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker

#Executing the Docker Command Without Sudo
sudo usermod -aG docker ${USER}
su - ${USER}
groups
sudo usermod -aG docker username
```
Ref :  https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04

## Step 1 - Genarate RKE cluster configuaration
```shell
rke config --empty
```
## Step 2 - Deploying RKE Cluster
```shell
rke up
cp kube_config_cluster.yml ~/.kube/
```

## Step 2 - Check RKE cluster
```shell
kubectl get nodes

NAME                          STATUS    ROLES                      AGE       VERSION
165.227.114.63                Ready     controlplane,etcd,worker   11m       v1.13.5
165.227.116.167               Ready     controlplane,etcd,worker   11m       v1.13.5
165.227.127.226               Ready     controlplane,etcd,worker   11m       v1.13.5
```
Note : 
https://rancher.com/docs/rancher/v2.5/en/installation/resources/k8s-tutorials/ha-rke/
https://computingforgeeks.com/install-kubernetes-production-cluster-using-rancher-rke/
## Step 3 - Install the cert manager
```
helm repo add jetstack https://charts.jetstack.io

kubectl create namespace cert-manager

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.5.1

kubectl get po --namespace cert-manager
```
## Step 4 - Install Rancher
```shell
helm repo add rancher-latest https://releases.rancher.com/server-charts/stable

kubectl create namespace cattle-system

helm install rancher-stable/rancher -name rancher --namespace cattle-system --set hostname=rancher.production.com --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=admin@gmail.com

kubectl -n cattle-system get deploy rancher
```

Ref:
https://www.youtube.com/watch?v=IEoyxoLqPVc
https://gist.github.com/kiranchavala/893ec350dd55f9fb4747b602208bb4fc
