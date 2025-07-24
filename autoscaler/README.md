# Kubernetes Autoscaling

This directory contains resources and guides for implementing various autoscaling strategies on Kubernetes.

Autoscaling is a critical component for managing modern, cloud-native applications, allowing your cluster to dynamically adjust to workload demands. This ensures performance during peak times and cost savings during lulls.

## Cloud-Specific Implementations

*   **[AWS](./aws/README.md)**: A comprehensive guide to three different autoscaling methods on Amazon EKS:
    1.  **Cluster Autoscaler**: For node-level scaling based on pod requests.
    2.  **EKS Auto Mode**: A simplified, managed autoscaling solution from AWS.
    3.  **Karpenter**: A flexible, high-performance cluster autoscaler.
