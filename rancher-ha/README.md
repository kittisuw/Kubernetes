# Rancher High Availability (HA) on a RKE Cluster
## Table of contents
  - [Prerequisites](#prerequisites)
  - [Step 1 - Prepare node for RKE](#step-1---prepare-node-for-rke)
  - [Step 2 - Prepare node for RKE Client](#step-2---prepare-node-for-rke-client)
  - [Step 3 - Deploy the RKE cluster without the ingress controller](#step-3---deploy-the-rke-cluster-without-the-ingress-controller)
  - [Step 4 - Check RKE cluster](#step-4---check-rke-cluster)
  - [Step 5 - Deploy MetalLB](#step-5---deploy-metallb)
  - [Step 6 - Install the cert manager](#step-6---install-the-cert-manager)
  - [Step 7 - Install nginx-ingress](#step-7---install-nginx-ingress)
  - [Step 8 - Install Rancher](#step-8---install-rancher)
## Prerequisites
1. Download RKE binary [Download](https://rancher.com/docs/rke/latest/en/installation/#download-the-rke-binary)
2. Prepare 3 VMs and install [Requirements](https://rancher.com/docs/rke/latest/en/os/)
3. helm
4. kubectl
5. kustomize
## Step 1 - Prepare node for RKE
```shell
##### Prepare the kubernetes nodes

#Disable swap and firewall
sudo ufw disable
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

#Update sysctl settings for Kubernetes networking
sudo -i 
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
exit
sudo sysctl --system

#Install docker
sudo apt-get update
sudo apt-get -y upgrade
curl https://releases.rancher.com/install-docker/20.10.sh | sh

#Add new User and add to docker group
sudo adduser rkeuser
sudo usermod -aG docker rkeuser
```
Ref :   
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04   
https://www.linkedin.com/pulse/deploy-highly-available-kubernetes-cluster-using-rancher-elemam/   
https://rancher.com/docs/rancher/v2.5/en/installation/requirements/installing-docker/   
## Step 2 - Prepare node for RKE Client
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

#Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

#Add mapping host by public IP
sudo vi /etc/hosts
...
#rancher
192.168.40.177 kbj-prod-k8s-rancher-01
192.168.40.178 kbj-prod-k8s-rancher-02
192.168.40.179 kbj-prod-k8s-rancher-03
...

#Set up passwordless SSH Logins on all nodes (Copy public key to all node)
ssh-keygen -t rsa -b 2048
ssh-copy-id rkeuser@kbj-prod-k8s-rancher-01
ssh-copy-id rkeuser@kbj-prod-k8s-rancher-02
ssh-copy-id rkeuser@kbj-prod-k8s-rancher-03
```
## Step 3 - Deploy the RKE cluster without the ingress controller
```shell
rke up
```
If you are adding/removing nodes in the cluster, after updating the cluster.yml run the following
```shell
rke up --update-only
```
Note that if you are deploying your Cluster in one of the popular cloud providers, you will want to consider registering that cloud provider so that your cluster can talk to the cloud environment for things like setting up volumes e.t.c.   
[RKE Cloud Provider Configuration](https://rancher.com/docs/rke/latest/en/config-options/cloud-providers/)
## Step 4 - Check RKE cluster
```shell
export KUBECONFIG=$(pwd)/kube_config_cluster.yml
kubectl get node
#By default, kubectl checks ~/.kube/config.You can copy this file to $HOME/.kube/config if you don’t have any other kubernetes cluster.

NAME                      STATUS   ROLES                      AGE     VERSION
kbj-prod-k8s-rancher-01   Ready    controlplane,etcd,worker   5h18m   v1.20.15
kbj-prod-k8s-rancher-02   Ready    controlplane,etcd,worker   5h18m   v1.20.15
kbj-prod-k8s-rancher-03   Ready    controlplane,etcd,worker   5h18m   v1.20.15
```
The files mentioned below are needed to maintain, troubleshoot and upgrade your cluster.   
Save a copy of the following files in a secure location:

rancher-cluster.yml: The RKE cluster configuration file.   
kube_config_cluster.yml: The Kubeconfig file for the cluster, this file contains credentials for full access to the cluster.   
rancher-cluster.rkestate: The Kubernetes Cluster State file, this file contains credentials for full access to the cluster.   
## Step 5 - Deploy MetalLB
  5.1 Install metallb
```shell
#Create namespace
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
#Install metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
#On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
#Check pod status
kubectl get pods -n metallb-system
```
  5.2 Apply configmap for metallb control over IPs
```shell
vi metallb/config.yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.40.183-192.168.40.183
---
kubectl apply -f metallb/config.yaml
```
Ref : https://medium.com/@jodywan/cloud-native-devops-11a-metallb-with-nginx-ingress-and-rancher-2da396c1ae70
## Step 6 - Install the cert manager   
* You should skip this step if you are bringing your own certificate files
```shell
# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
# Update your local Helm chart repository cache
helm repo update
# Install the CustomResourceDefinition resources separately
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml
# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.5.1
# Check running pod
kubectl get pods -n cert-manager
```
## Step 7 - Install nginx-ingress
```shell
#Install rancher
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --version 4.0.13 \
    --namespace ingress-nginx --create-namespace \
    -f ingress-nginx/internal-ingress.yaml \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux
#Check running pod
k get po -n ingress-nginx
```
## Step 8 - Install Rancher
```shell
# Add the Helm Chart Repositorylink
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

# Update your local Helm chart repository cache
helm repo update

# Create a Namespace for Rancher
kubectl create namespace cattle-system

# Install Rancher with Helm
helm install rancher rancher-stable/rancher \
  --version 2.6.4 \
  --namespace cattle-system \
  --set hostname=rancher.kbjcapital.co.th \
  --set replicas=3

# Verify that the Rancher Server is Successfully Deployed
kubectl -n cattle-system rollout status deploy/rancher
kubectl -n cattle-system get deploy rancher
```
Reference:    
Install rancher ok K8s : https://rancher.com/docs/rancher/v2.5/en/installation/install-rancher-on-k8s/   
Rancher release : https://github.com/rancher/rke/releases   
Port requirement : https://rancher.com/docs/rancher/v2.5/en/installation/requirements/ports/     
Rancher install using your own Certificates : https://github.com/odytrice/kubernetes/blob/master/rancher.md  
Install nginx-ingress : https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm


