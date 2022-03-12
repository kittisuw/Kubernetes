# How to install ingress-nginx
## Table of contents
  - [Prerequisites](#prerequisites)
  - [Step 1 - Install ingress-nginx](#step-1---install-ingress-nginx)
  - [Step 2 - Wait until is ready to process requests running](#step-2---wait-until-is-ready-to-process-requests-running)
  - [Step 3 - The following example creates simple http-echo services and an Ingress object to route to these services](#step-3---the-following-example-creates-simple-http-echo-services-and-an-ingress-object-to-route-to-these-services)
  - [Step 4 - Verify that the ingress works](#step-4---verify-that-the-ingress-works)
## Step 1 - Install ingress-nginx
```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```
Note: https://github.com/kubernetes/ingress-nginx/tree/main/deploy/static/provider/kind
## Step 2 - Wait until is ready to process requests running
```shell
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```
The output looks similar to the following:
```shell
pod/ingress-nginx-controller-59cbb6ccb6-xjxz7 condition met
```
## Step 3 - The following example creates simple http-echo services and an Ingress object to route to these services
```shell
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: foo
spec:
  containers:
  - name: foo-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=foo"
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
spec:
  selector:
    app: foo
  ports:
  # Default port used by the image
  - port: 5678
---
kind: Pod
apiVersion: v1
metadata:
  name: bar-app
  labels:
    app: bar
spec:
  containers:
  - name: bar-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=bar"
---
kind: Service
apiVersion: v1
metadata:
  name: bar-service
spec:
  selector:
    app: bar
  ports:
  # Default port used by the image
  - port: 5678
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: "/foo"
        backend:
          service:
            name: foo-service
            port:
              number: 5678
      - pathType: Prefix
        path: "/bar"
        backend:
          service:
            name: bar-service
            port:
              number: 5678
---
```
Apply
```shell
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml
```
## Step 4 - Verify that the ingress works
```shell
# should output "foo"
curl localhost/foo
# should output "bar"
curl localhost/bar
```
## Reference
 - https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx


