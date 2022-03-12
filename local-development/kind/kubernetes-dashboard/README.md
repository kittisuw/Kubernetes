# How to install ingress-nginx
## Table of contents
  - [Prerequisites](#prerequisites)
  - [Step 4 - Verify that the ingress works](#step-4---verify-that-the-ingress-works)
## Prerequisites
1. [Install cluster](../README.md)
## Step 1 - Install Kubernetes dashboard
```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
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
## Step 3 - Get token for access dashboard
```shell
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```
## Step 4 - Set port-forwarding
```shell
kubectl proxy
```
Dashboard available at : http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

## Reference
 - [Setting Up An Ingress Controller](https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx)

