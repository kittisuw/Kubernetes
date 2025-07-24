# Kubernetes Autoscaling on AWS EKS

This guide provides instructions for setting up three different autoscaling methods on an AWS EKS cluster:

1.  **Cluster Autoscaler**: Adjusts the number of nodes in your cluster based on pod resource requests.
2.  **EKS Auto Mode**: A simplified, managed autoscaling solution from AWS.
3.  **Karpenter**: An open-source, flexible, high-performance Kubernetes cluster autoscaler built by AWS that provisions new nodes in response to unschedulable pods.

---

## Method 1: Cluster Autoscaler

This method involves the traditional Kubernetes Cluster Autoscaler that interacts with AWS Auto Scaling Groups.

### Prerequisites

*   An existing EKS cluster with managed node groups or self-managed Auto Scaling Groups.
*   `kubectl` configured to connect to your EKS cluster.

### 1. Deploy the Cluster Autoscaler.  
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
### 2. Prevent CA From Evicting Itself
```bash
kubectl -n kube-system annotate deployment cluster-autoscaler \
  cluster-autoscaler.kubernetes.io/safe-to-evict="false"
```
### 3. Verify the Deployment

Check the logs to ensure it's running correctly.

```bash
kubectl logs -f deployment/cluster-autoscaler-autoscaler -n kube-system
```

---

## Method 2: EKS Auto Mode

EKS Auto Mode simplifies cluster creation and management by providing a pre-configured, autoscaling cluster. This is the easiest way to get started with a hands-off, autoscaling EKS cluster.

### Creating an EKS Auto Mode Cluster

1.  **Open the EKS Console**: Navigate to the Amazon EKS console in the AWS Management Console.

2.  **Start Cluster Creation**: Click the "Create cluster" button.

3.  **Select Quick Configuration**: Ensure the "Quick configuration" option is selected. This is the default for EKS Auto Mode.

4.  **Configure Cluster Basics**:
    *   **Name**: Give your cluster a unique name.
    *   **Kubernetes version**: Select your desired Kubernetes version.
    *   **Cluster IAM Role**: Choose an existing EKS cluster role or create a new one.
    *   **Node IAM Role**: Choose an existing EKS node role or create a new one.

5.  **Configure Networking**:
    *   **VPC**: Select an existing VPC or create a new one for your cluster.

6.  **Review and Create**: Review the default settings and click "Create cluster".

EKS will provision an Auto Mode cluster with a default configuration that includes automatic scaling of nodes and pods, managed by AWS.

### Accessing the Cluster

If you are using AWS IAM Identity Center (AWS SSO) for authentication, first log in to obtain temporary credentials. If you use a named profile, be sure to specify it.

```bash
aws sso login
```

Once authenticated, run the following command to configure `kubectl`:

```bash
aws eks update-kubeconfig --region ap-southeast-1 --name <your-cluster-name> # Singapore
```

---

## Method 3: Karpenter

Karpenter is a modern, high-performance cluster autoscaler that provisions nodes directly, bypassing the need for node groups.

### Prerequisites

*   An EKS cluster version 1.20 or later.
*   `kubectl`, `helm`, and AWS CLI installed.
*   Permissions to create IAM roles and instance profiles.

### 1. Set Environment Variables

```bash
export CLUSTER_NAME="<your-cluster-name>"
export AWS_REGION="ap-southeast-1" # Region
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

### 2. Create IAM Resources

Karpenter requires an IAM role for its controller and an EC2 instance profile for the nodes it creates. `eksctl` can automate this.

Create the `karpenter-cloudformation.yaml` template:
```bash
eksctl create iamserviceaccount \
  --cluster "${CLUSTER_NAME}" \
  --name karpenter \
  --namespace karpenter \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}" \
  --role-name "KarpenterControllerRole-${CLUSTER_NAME}" \
  --approve
```

### 3. Install Karpenter with Helm

Add the Karpenter Helm repository and install it.

```bash
helm repo add karpenter https://charts.karpenter.sh/
helm repo update

helm upgrade --install karpenter karpenter/karpenter \
  --namespace karpenter \
  --create-namespace \
  --set serviceAccount.create=false \
  --set controller.clusterName=${CLUSTER_NAME} \
  --set controller.clusterEndpoint=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output text) \
  --wait
```

### 4. Create a Provisioner

A Provisioner tells Karpenter what kind of nodes to create. Save as `default-provisioner.yaml`:

```yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand"]
  limits:
    resources:
      cpu: 1000
  providerRef:
    name: default
  ttlSecondsAfterEmpty: 30
---
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
```

Apply it: `kubectl apply -f default-provisioner.yaml`

### 5. Verify the Installation

Check the Karpenter controller logs:

```bash
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter
```

You can now test it by deploying pods that are too large for existing nodes, and Karpenter will provision a new node to fit them.

### 6. Accessing the Cluster

If you are using AWS IAM Identity Center (AWS SSO) for authentication, first log in to obtain temporary credentials. If you use a named profile, be sure to specify it.

```bash
aws sso login
```

Once authenticated, run the following command to configure `kubectl`:

```bash
aws eks update-kubeconfig --region ap-southeast-1 --name <your-cluster-name> # Singapore
```