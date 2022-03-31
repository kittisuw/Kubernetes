# Deploy rancher HA mode on RKE
## Table of contents
  - [Prerequisites](#prerequisites)
  - [Step 1 - Download RKE Binary](#step-1---download-rke-binary)
## Prerequisites
1. Download RKE binary [Dowload](https://rancher.com/docs/rke/latest/en/installation/#download-the-rke-binary)
2. Prepare 3 VMs and install [Requirements](https://rancher.com/docs/rke/latest/en/os/)
3. helm
4. kubectl

## Step 1 - Install kubectl,RKE client
```shell
#Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

#Install RKE
wget https://github.com/rancher/rke/releases/download/v1.2.19/rke_linux-amd64
sudo cp rke_linux-amd64 /usr/local/bin/rke
sudo chmod +x /usr/local/bin/rke
which rke
rke --help
```
Ref: https://github.com/rancher/rke/releases
## Step 2 - Prepare node for RKE
```shell
##### Prepare the kubernetes nodes

#Disable swap and firewall
ufw disable
swapoff -a; sed -i '/swap/d' /etc/fstab

#Update sysctl settings for Kubernetes networking
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

#Install docker
sudo apt-get update
sudo apt-get -y upgrade
curl https://releases.rancher.com/install-docker/20.10.sh | sh

#Add new User and add to docker group
sudo adduser rkeuser
#sudo passwd rkeuser >/dev/null 2>&1
sudo usermod -aG docker rkeuser

#Set up passwordless SSH Logins on all nodes (Copy public key to all node)
ssh-keygen -t rsa -b 2048
ssh-copy-id rkeuser@172.17.1.100
ssh-copy-id rkeuser@172.17.1.101
ssh-copy-id rkeuser@172.17.1.102
```
Ref :   
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04   
https://www.linkedin.com/pulse/deploy-highly-available-kubernetes-cluster-using-rancher-elemam/   
https://rancher.com/docs/rancher/v2.5/en/installation/requirements/installing-docker/   
## Step 3 - Genarate RKE cluster configuaration
```shell
rke config --empty
```
## Step 4 - Deploying RKE Cluster
```shell
rke up
```

## Step 5 - Check RKE cluster
```shell
kubectl --kubeconfig ./kube_config_cluster.yml get node
#or 
cp kube_config_cluster.yml ~/.kube/config
kubectl get node
#By default, kubectl checks ~/.kube/config

NAME                          STATUS    ROLES                      AGE       VERSION
165.227.114.63                Ready     controlplane,etcd,worker   11m       v1.13.5
165.227.116.167               Ready     controlplane,etcd,worker   11m       v1.13.5
165.227.127.226               Ready     controlplane,etcd,worker   11m       v1.13.5
```
Note :   
https://rancher.com/docs/rancher/v2.5/en/installation/resources/k8s-tutorials/ha-rke/   
https://computingforgeeks.com/install-kubernetes-production-cluster-using-rancher-rke/
## Step 6 - Install the cert manager
```
helm repo add jetstack https://charts.jetstack.io

kubectl create namespace cert-manager

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.5.1

kubectl get po --namespace cert-manager
```
## Step 7 - Install Rancher
```shell
helm repo add rancher-latest https://releases.rancher.com/server-charts/stable

kubectl create namespace cattle-system

helm install rancher-stable/rancher -name rancher --namespace cattle-system --set hostname=rancher.production.com --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=admin@gmail.com

kubectl -n cattle-system get deploy rancher
```

Ref:   
https://www.youtube.com/watch?v=IEoyxoLqPVc   
https://gist.github.com/kiranchavala/893ec350dd55f9fb4747b602208bb4fc   
https://blog.tekspace.io/rancher-kubernetes-single-node-setup   
https://cloudraya.com/knowledge-base/high-availability-kubernetes-using-rke-in-cloudraya-part-1/   
https://itnext.io/setup-a-basic-kubernetes-cluster-with-ease-using-rke-a5f3cc44f26f   
https://www.youtube.com/watch?v=I9kNkoWdlwc   

