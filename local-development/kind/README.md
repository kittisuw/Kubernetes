# Create Kubernetes local development with [kind](https://kind.sigs.k8s.io)
## Table of contents
  - [Prerequisites](#prerequisites)
  - [Step 1 - Create Kubernetes cluster(1 Master 2 Worker)](#step-1---create-kubernetes-cluster1-master-2-worker)
  - [Step 2 - Get Cluster information](#step-2---get-cluster-information)
  - [Step 3 - Get Cluster node information](#step-3---get-cluster-node-information)
  - [Advance](#advance)
  - [Clean up](#clean-up)
  - [Reference](#reference)
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
Note:   
If you need 1 node just remove line content `- role: worker`   
List version available https://hub.docker.com/r/kindest/node/tags

The output looks similar to the following:
```shell
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
## Step 3 - Get Cluster node information
```
kubectl get node
```
The output looks similar to the following:
```
NAME                         STATUS   ROLES                  AGE     VERSION
test-cluster-control-plane   Ready    control-plane,master   2m44s   v1.22.5
test-cluster-worker          Ready    <none>                 2m7s    v1.22.5
test-cluster-worker2         Ready    <none>                 2m7s    v1.22.5
```
## Advance
- [Deploy ingress-nginx](ingress/../ingress-nginx/README.md)
- [Deploy and Access the Kubernetes Dashboard](kubernetes-dashboard/README.md)
## Clean up
```shell
kind delete cluster test-cluster
```
The output looks similar to the following:
```
Deleted clusters: ["test-cluster"]
```
## Reference
- [kind Quick start](https://kind.sigs.k8s.io/docs/user/quick-start/)
  