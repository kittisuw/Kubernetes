# Karpenter Installation Guide on Amazon EKS

## ✅ Prerequisites

* EKS cluster already created
* IAM OIDC provider enabled on the EKS cluster (see step below)
* Tools installed: `aws`, `eksctl`, `helm`, `kubectl`
* IAM role with permissions to create IAM roles and instance profiles (or coordinate with AWS admin if using SSO)

---

## 🔑 How to Enable IAM OIDC Provider on EKS

To allow EKS workloads (e.g., Karpenter controller) to assume IAM roles via IRSA (IAM Roles for Service Accounts), enable the OIDC provider:

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster <your-cluster-name> \
  --approve
```

This command requires the following IAM permissions:

```json
{
  "Effect": "Allow",
  "Action": [
    "iam:GetOpenIDConnectProvider",
    "iam:CreateOpenIDConnectProvider",
    "iam:TagOpenIDConnectProvider"
  ],
  "Resource": "*"
}
```

If using AWS SSO, ensure your assigned role has these permissions.

---

## 1. Add Karpenter Helm Repository

```bash
helm repo add karpenter https://charts.karpenter.sh
helm repo update
```

---

## 🔐 Required IAM Permissions (for Steps 2, 3, 4, and 5)

If you are using AWS SSO, ensure the Permission Set includes the following actions:

```json
{
  "Effect": "Allow",
  "Action": [
    "iam:CreateRole",
    "iam:AttachRolePolicy",
    "iam:PassRole",
    "iam:GetRole",
    "iam:TagRole",
    "iam:CreateInstanceProfile",
    "iam:AddRoleToInstanceProfile",
    "iam:CreateServiceLinkedRole",
    "iam:GetInstanceProfile"
  ],
  "Resource": "*"
}
```

This allows creating IAM roles, attaching policies, configuring Karpenter controller IAM identity, and setting up instance profiles and service-linked roles used by EC2 and Karpenter provisioning.

---

## 2. Create IAM Role for Karpenter Controller

```bash
CLUSTER_NAME="<your-cluster-name>"
AWS_REGION="<your-region>"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

eksctl utils associate-iam-oidc-provider \
  --cluster $CLUSTER_NAME \
  --approve

eksctl create iamserviceaccount \
  --name karpenter \
  --namespace karpenter \
  --cluster $CLUSTER_NAME \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore \
  --approve
```

---

## 3. Install Karpenter using Helm

```bash
helm upgrade --install karpenter karpenter/karpenter \
  --namespace karpenter --create-namespace \
  --set serviceAccount.create=false \
  --set serviceAccount.name=karpenter \
  --set settings.aws.clusterName=$CLUSTER_NAME \
  --set settings.aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-$CLUSTER_NAME \
  --set settings.aws.interruptionQueueName=karpenter-interruption-queue \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi
```

---

## 4. Create EC2 Instance Profile for Nodes (One-time setup)

```bash
aws iam create-instance-profile \
  --instance-profile-name KarpenterNodeInstanceProfile-$CLUSTER_NAME

aws iam add-role-to-instance-profile \
  --instance-profile-name KarpenterNodeInstanceProfile-$CLUSTER_NAME \
  --role-name <EC2NodeRole>
```

---

## 5. Create Karpenter Provisioner

```yaml
# provisioner.yaml
apiVersion: karpenter.sh/v1beta1
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: "node.kubernetes.io/instance-type"
      operator: In
      values: ["t3.medium", "t3.large"]
  limits:
    resources:
      cpu: 1000
  providerRef:
    name: default
  ttlSecondsAfterEmpty: 60
```

```bash
kubectl apply -f provisioner.yaml
```

---

## 6. Deploy Sample Workload to Trigger Autoscaling

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate
spec:
  replicas: 1
  selector:
    matchLabels:
      app: inflate
  template:
    metadata:
      labels:
        app: inflate
    spec:
      containers:
      - name: inflate
        image: public.ecr.aws/eks-distro/kube-apiserver:v1.27.1
        resources:
          requests:
            cpu: "2"
            memory: "1Gi"
```

```bash
kubectl apply -f inflate.yaml
```

---

## ✅ Notes

* No need to create managed node groups manually.
* Ensure your IAM user/role has required permissions if using AWS SSO.
* Monitor logs using:

```bash
kubectl logs -n karpenter deployment/karpenter
```


REF : 
https://karpenter.sh/v1.0/getting-started/migrating-from-cas/.  
https://www.youtube.com/watch?v=dS6UIovSXpA&t=532s