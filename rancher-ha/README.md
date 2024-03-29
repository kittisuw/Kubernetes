# Rancher High Availability (HA) on a RKE Cluster   
![rke-setup](asset/../assets/images/rke-setup.jpeg)
## Table of contents
  - [Prerequisites](#1)
  - [Step 1 - Prepare 3 VMs for RKE nodes](#step-1---prepare-3-vms-for-rke-nodes)
  - [Step 2 - Prepare RKE Client](#step-2---prepare-workstation-or-vm-for-rke-client)
  - [Step 3 - Deploy the RKE cluster without the ingress controller](#step-3---deploy-the-rke-cluster-without-the-ingress-controller)
  - [Step 4 - Check RKE cluster](#step-4---check-rke-cluster)
  - [Step 5 - Deploy MetalLB](#step-5---deploy-metallb)
  - [Step 6 - Install the cert manager](#step-6---install-the-cert-manager)
  - [Step 7 - Install NGINX Ingress Controller](#step-7---install-nginx-ingress-controller)
  - [Step 8 - Install Rancher](#step-8---install-rancher)
  - [Step 9 - Create Ingress resource](#step-9---create-ingress-resource)
## Prerequisites
1. Download RKE binary [Download](https://rancher.com/docs/rke/latest/en/installation/#download-the-rke-binary) @RKE Client
2. CLI Tools: [kubectl](https://kubernetes.io/docs/tasks/tools/#install-kubectl), [helm](https://docs.helm.sh/using_helm/#installing-helm) @RKE Client   
3. Prepare 3 VMs and install [Requirements](https://rancher.com/docs/rke/latest/en/os/)
## Step 0 - Clone this repository
```
git clone xxx
```
## Step 1 - Prepare 3 VMs for RKE nodes
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
## Step 2 - Prepare Workstation or VM for RKE Client
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
192.168.40.177 prod-k8s-rancher-01
192.168.40.178 prod-k8s-rancher-02
192.168.40.179 prod-k8s-rancher-03
...

#Set up passwordless SSH Logins on all nodes (Copy public key to all node)
ssh-keygen -t rsa -b 2048
ssh-copy-id rkeuser@prod-k8s-rancher-01
ssh-copy-id rkeuser@prod-k8s-rancher-02
ssh-copy-id rkeuser@prod-k8s-rancher-03
```
## Step 3 - Deploy the RKE cluster without the ingress controller
```shell
cd assets/manifests/rke
rke up
```
If you are adding/removing nodes in the cluster or upgrade Kubernetes version, after updating the cluster.yml run the following
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
prod-k8s-rancher-01   Ready    controlplane,etcd,worker   5h18m   v1.20.15
prod-k8s-rancher-02   Ready    controlplane,etcd,worker   5h18m   v1.20.15
prod-k8s-rancher-03   Ready    controlplane,etcd,worker   5h18m   v1.20.15
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
#Create memberlist on first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
#Install metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
#Check pod status
kubectl get pods -n metallb-system
```
  5.2 Apply configmap for metallb control over IPs
```shell
vi assets/manifests/metallb/config.yaml
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
      - 192.168.40.183-192.168.40.183  #This line is Loadbalancer IP
---
kubectl apply -f assets/manifests/metallb/config.yaml
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
## Step 7 - Install NGINX Ingress Controller
```shell
#Install NGINX Ingress Controller
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --version 4.0.13 \
    --namespace ingress-nginx --create-namespace \
    -f assets/manifests/ingress-nginx/internal-ingress.yaml \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux
#Check running pod
k get po -n ingress-nginx
```
## Step 8 - Install Rancher
```shell
#Add the Helm Chart Repositorylink
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
#Update your local Helm chart repository cache
helm repo update
#Create a Namespace for Rancher
kubectl create namespace cattle-system
#Install Rancher with Helm
helm install rancher rancher-stable/rancher \
  --version 2.6.4 \
  --namespace cattle-system \
  --set hostname=rancher.mydomain.com \
  --set replicas=3
#Verify that the Rancher Server is Successfully Deployed
kubectl -n cattle-system rollout status deploy/rancher
kubectl -n cattle-system get deploy rancher

#If you provided your own bootstrap password during installation, browse to https://rancher.mydomain.com to get started.
#If this is the first time you installed Rancher, get started by running this command and clicking the URL it generates:
echo https://rancher.mydomain.com/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')
#To get just the bootstrap password on its own, run:
kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'
```
## Step 9 - Create Ingress resource
  Create ingress resource and brows to https://rancher.mydomain.com
```shell
#Create ingress resource
k apply -f ingress-nginx/rancher-ingress.yaml
#Check ingress resorce
k get ing -n cattle-system
NAME          CLASS    HOSTS                      ADDRESS          PORTS     AGE
rancher       <none>   rancher.mydomain.com                    80, 443   40h
rancher-ing   <none>   rancher.mydomain.com   192.168.40.183   80        6m34s
```
## Reference    
Install rancher on K8s : https://docs.ranchermanager.rancher.io/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster   
Rancher release : https://github.com/rancher/rke/releases   
Port requirement : https://docs.ranchermanager.rancher.io/getting-started/installation-and-upgrade/installation-requirements/port-requirements       
Rancher install using your own Certificates : https://github.com/odytrice/kubernetes/blob/master/rancher.md  
Install nginx-ingress : https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm   
Building a Highly Available Kubernetes Cluster : https://www.suse.com/c/rancher_blog/building-a-highly-available-kubernetes-cluster/
Nginx-ingress configuration : https://loft.sh/blog/kubernetes-nginx-ingress-10-useful-configuration-options/
Nginx-ingress own TLS : https://docs.microsoft.com/en-us/azure/aks/ingress-own-tls