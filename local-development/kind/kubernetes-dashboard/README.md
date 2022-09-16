# Deploy and Access the Kubernetes Dashboard
## Table of contents
  - [Prerequisites](#prerequisites)
  - [Step 1 - Install Kubernetes dashboard](#step-1---install-kubernetes-dashboard)
  - [Step 2 - Create service Account](#step-2---create-service-account)
  - [Step 3 - Get token for access dashboard](#step-3---get-token-for-access-dashboard)
  - [Step 4 - Set port-forwarding](#step-4---set-port-forwarding)
  - [Step 5 - Create Kubernetes test resorce Eg. pod with log 100mb](#step-5---create-kubernetes-test-resorce-eg-pod-with-log-100mb)
  - [Reference](#reference)
## Prerequisites
1. [Install cluster](../README.md)
## Step 1 - Install Kubernetes dashboard
```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
```
## Step 2 - Create service Account
```shell
cat <<EOF |kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```
## Step 3 - Creating a ClusterRoleBinding
```shell
cat <<EOF |kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```
## Step 3 - Getting a Bearer Token
```shell
kubectl -n kubernetes-dashboard create token admin-user
```
## Step 4 - Set port-forwarding
```shell
kubectl proxy
```
Dashboard available at : http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

## Step 5 - Create Kubernetes test resorce Eg. pod with log 100mb
```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/test-resources/100mb-of-logs-pod.yaml
```
## Reference
 - [Deploy and Access the Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
 - [Kubernetes dashbord test resource](https://github.com/kubernetes/dashboard/tree/master/aio/test-resources)