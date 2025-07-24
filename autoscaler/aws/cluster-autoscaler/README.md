# Cluster Autoscaler on AWS EKS

This guide details the setup of the traditional Kubernetes Cluster Autoscaler, which dynamically adjusts the number of nodes in your cluster by interacting with AWS Auto Scaling Groups.

### Prerequisites

*   An existing EKS cluster with managed node groups or self-managed Auto Scaling Groups.
*   `kubectl` configured to connect to your EKS cluster.
### 1. Create a new Node group.  
### 2. Deploy the Cluster Autoscaler.  
Deploy the Cluster Autoscaler using the official Helm chart.

```bash
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update
```
```bash
CLUSTER_NAME="<your-cluster-name>"
AWS_REGION="ap-southeast-1" #Region
```
```bash
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler 
  --namespace kube-system 
  --set awsRegion=${AWS_REGION} 
  --set autoDiscovery.clusterName=${CLUSTER_NAME} 
  --set extraArgs.expander=least-waste 
  --set extraArgs.skip-nodes-with-local-storage=false 
  --set extraArgs.balance-similar-node-groups=true 
  --set extraArgs.node-group-auto-discovery="asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler=${CLUSTER_NAME}" 
  --set rbac.serviceAccount.create=true 
  --set rbac.serviceAccount.name=cluster-autoscaler 
  --set image.tag=v1.32.2 
  --wait
# v1.32.2 matches Kubernetes v1.29.x
```
### 3. Prevent CA From Evicting Itself
```bash
kubectl -n kube-system annotate deployment cluster-autoscaler \
  cluster-autoscaler.kubernetes.io/safe-to-evict="false"
```
### 4. Verify the Deployment

Check the logs to ensure it's running correctly.

```bash
kubectl logs -f deployment/cluster-autoscaler-autoscaler -n kube-system
```

### 5. Scale test
```bash
# ca-test.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ca-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ca-test
  template:
    metadata:
      labels:
        app: ca-test
    spec:
      containers:
      - name: ca-test
        image: nginx
        resources:
          requests:
            cpu: "4"       # ต้องเกิน resource ที่ node ปัจจุบันมี
            memory: "4Gi"
```
```bash
kubectl apply -f ca-test.yaml
```
```bash
kubectl -n kube-system logs -l app.kubernetes.io/name=cluster-autoscaler --tail=100 -f
```
```bash
No schedulable nodes for pending pod
Scale-up: setting desired capacity from 1 to 2
```
Confirm Node
```bash
kubectl get nodes
```
Delete Deployment
```
kubectl delete -f  ca-test.yaml
```
### 6. Cordon All Nodes in Target Old Node Group
```bash
kubectl get nodes -l eks.amazonaws.com/nodegroup=nonprod-nodegroup
kubectl cordon <each-node-name>
```

### 7. Decommission Old Node Group
```bash
# Step 1: Drain each node
kubectl drain <each-node-name> --ignore-daemonsets

# Step 2: Ensure workloads are rescheduled
kubectl get pods -A -o wide

# Step 3: Check CA stability
kubectl -n kube-system logs -l app.kubernetes.io/name=cluster-autoscaler --tail=100

# Step 4: Delete node group via AWS Console
```
### ℹ️ Cluster Autoscaler Behavior

| Action         | Trigger                                        | Timeframe           |
| -------------- | ---------------------------------------------- | ------------------- |
| **Scale-Up**   | When pods are pending due to lack of resources | ~2–3 mins          |
| **Scale-Down** | When nodes are underutilized for ~10 minutes  | ~10 mins (tunable) |

> Tunables like `--scale-down-delay-after-add` can adjust behavior.