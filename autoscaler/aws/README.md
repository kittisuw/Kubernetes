# Kubernetes Autoscaling on AWS EKS

This guide provides instructions for setting up three different autoscaling methods on an AWS EKS cluster:

1.  **[Cluster Autoscaler](./cluster-autoscaler/README.md)**: Adjusts the number of nodes in your cluster based on pod resource requests.
2.  **[EKS Auto Mode](./eks-auto-mode/README.md)**: A simplified, managed autoscaling solution from AWS.
3.  **[Karpenter](./karpenter/README.md)**: An open-source, flexible, high-performance Kubernetes cluster autoscaler built by AWS that provisions new nodes in response to unschedulable pods.
