# How to create Kubernetes local development
## Table of contents
  - [Prerequisites](#prerequisites)
## Prerequisites
1. [Docker Desktop](https://docs.docker.com/desktop)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/)
3. [kubectx + kubens](https://github.com/ahmetb/kubectx) Tools for switch `Kubernetes` contexts(Clusters) and namespaces easily(Option)
## Step 1 - Create Kubernetes cluster(1 Master 2 Worker)
```shell
CLUSTER_NAME=test-cluster
CLUSER_VERSION=1.22.5
cat <<EOF | kind create cluster --name ${CLUSTER_NAME} --image kindest/node:v${CLUSER_VERSION} --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF
```
Note: If you need 1 node just remove line content `- role: worker`   
The output looks similar to the following:
```
Creating cluster "test-cluster" ...
 ✓ Ensuring node image (kindest/node:v1.22.5) 🖼 
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-test-cluster"
You can now use your cluster with:

kubectl cluster-info --context kind-test-cluster

Have a nice day! 👋
```
## Step 2 - Get Cluster information
```shell
kind get clusters
```
The output looks similar to the following:
```shell
test-cluster
```
Get cluster node information
```
kubectl get node
```
