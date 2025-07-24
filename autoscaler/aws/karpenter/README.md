# Karpenter on AWS EKS

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