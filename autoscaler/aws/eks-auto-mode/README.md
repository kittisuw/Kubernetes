# EKS Auto Mode on AWS EKS

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