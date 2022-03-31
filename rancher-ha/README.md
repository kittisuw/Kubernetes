# Deploy rancher HA mode on RKE
## Table of contents
  - [Prerequisites](#prerequisites)
  - [Step 1 - Download RKE Binary](#step-1---download-rke-binary)
## Prerequisites
1. Download RKE binary [Dowload](https://rancher.com/docs/rke/latest/en/installation/#download-the-rke-binary)
2. Prepare 3 VMs and install [Requirements](https://rancher.com/docs/rke/latest/en/os/)
3. helm
4. kubectl

## Step 1 - Prepare node for RKE
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
10.51.234.165 rke-poc-0001
10.51.138.250 rke-poc-0002
10.51.204.135 rke-poc-0003
...

#Set up passwordless SSH Logins on all nodes (Copy public key to all node)
ssh-keygen -t rsa -b 2048
ssh-copy-id rkeuser@rke-poc-0001
ssh-copy-id rkeuser@rke-poc-0002
ssh-copy-id rkeuser@rke-poc-0003
```
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
export KUBECONFIG=$(pwd)/kube_config_cluster.yml
kubectl get node
#By default, kubectl checks ~/.kube/config.You can copy this file to $HOME/.kube/config if you don’t have any other kubernetes cluster.

NAME           STATUS   ROLES                      AGE   VERSION
rke-poc-0001   Ready    controlplane,etcd,worker   19m   v1.20.15
rke-poc-0002   Ready    controlplane,etcd,worker   19m   v1.20.15
rke-poc-0003   Ready    controlplane,etcd,worker   19m   v1.20.15
```
Note :   
https://rancher.com/docs/rancher/v2.5/en/installation/resources/k8s-tutorials/ha-rke/   
https://computingforgeeks.com/install-kubernetes-production-cluster-using-rancher-rke/

## Step x - Install metal-lb with nginx-ingress
```shell
https://www.youtube.com/watch?v=iqVt5mbvlJ0
```
## Step 6 - Install the cert manager   
* You should skip this step if you are bringing your own certificate files
```shell
# If you have installed the CRDs manually instead of with the `--set installCRDs=true` option added to your Helm install command, you should upgrade your CRD resources before upgrading the Helm chart:
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.5.1

kubectl get po --namespace cert-manager
```
## Step 7 - Install Rancher
```shell
helm repo add rancher-latest https://releases.rancher.com/server-charts/stable

kubectl create namespace cattle-system

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.my.org \
  --set replicas=3 \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=me@example.org \
  --set letsEncrypt.ingress.class=nginx

kubectl -n cattle-system get deploy rancher
```

Ref:   
https://www.youtube.com/watch?v=IEoyxoLqPVc   
https://gist.github.com/kiranchavala/893ec350dd55f9fb4747b602208bb4fc   
https://blog.tekspace.io/rancher-kubernetes-single-node-setup   
https://cloudraya.com/knowledge-base/high-availability-kubernetes-using-rke-in-cloudraya-part-1/   
https://itnext.io/setup-a-basic-kubernetes-cluster-with-ease-using-rke-a5f3cc44f26f   
https://www.youtube.com/watch?v=I9kNkoWdlwc   

Install rancher ok K8s : https://rancher.com/docs/rancher/v2.5/en/installation/install-rancher-on-k8s/   
Rancher release : https://github.com/rancher/rke/releases   
Port requirement : https://rancher.com/docs/rancher/v2.5/en/installation/requirements/ports/
install RKE : https://www.youtube.com/watch?v=1j5lhDzlFUM