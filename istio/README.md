# Deploy Istio
## Table of contents
  - [Prerequisites](#prerequisites)
## Prerequisites
1. Kubernetes cluster or Kubernetes local development with [kind](../local-development/kind/README.md)   
2. Kubernetes client [kubectl](https://kubernetes.io/docs/tasks/tools/)
## Step 1 - Check Kubernetes cluster
```shell
kubectl get node
NAME                  STATUS     ROLES                  AGE   VERSION
istio-control-plane   NotReady   control-plane,master   14s   v1.23.0
```
## Step 2 - Install istio CLI specific version Eg. 1.13.1
```shell
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.13.1 TARGET_ARCH=x86_64 sh -
cd istio-1.13.1
export PATH=$PWD/bin:$PATH
```
## Step 3 - Check istio CLI version
```shell
istioctl version
```
The output looks similar to the following:
```shell
no running Istio pods in "istio-system"
1.13.1
```
## Step 4 - Check compatability with target cluster
```shell
istioctl x precheck
```
The output looks similar to the following:
```shell
✔ No issues found when checking the cluster. Istio is safe to install or upgrade!
  To get started, check out https://istio.io/latest/docs/setup/getting-started/
```
## Step 5 - Check Available istio profile
```shell
istioctl profile list
```
The output looks similar to the following:
```shell
    default
    demo
    empty
    external
    minimal
    openshift
    preview
    remote
```
Notes:[Istio profile](https://istio.io/latest/docs/setup/additional-setup/config-profiles)
##  Step 6 - Install istio with default profile *This profile is recommended for production
```shell
istioctl install --set profile=default
```
The output looks similar to the following:
```shell
This will install the Istio 1.13.1 default profile with ["Istio core" "Istiod" "Ingress gateways"] components into the cluster. Proceed? (y/N) y
✔ Istio core installed
✔ Istiod installed
✔ Ingress gateways installed
✔ Installation complete
Making this installation the default for injection and validation.

Thank you for installing Istio 1.13.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/pzWZpAvMVBecaQ9h9
```
## Step 7 - Verify installation
```shell
istioctl verify-install
```
The output looks similar to the following:
```shell
1 Istio control planes detected, checking --revision "default" only
✔ ClusterRole: istiod-istio-system.istio-system checked successfully
✔ ClusterRole: istio-reader-istio-system.istio-system checked successfully
✔ ClusterRoleBinding: istio-reader-istio-system.istio-system checked successfully
✔ ClusterRoleBinding: istiod-istio-system.istio-system checked successfully
✔ ServiceAccount: istio-reader-service-account.istio-system checked successfully
✔ Role: istiod-istio-system.istio-system checked successfully
✔ RoleBinding: istiod-istio-system.istio-system checked successfully
✔ ServiceAccount: istiod-service-account.istio-system checked successfully
✔ CustomResourceDefinition: wasmplugins.extensions.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: destinationrules.networking.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: envoyfilters.networking.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: gateways.networking.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: proxyconfigs.networking.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: serviceentries.networking.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: sidecars.networking.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: virtualservices.networking.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: workloadentries.networking.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: workloadgroups.networking.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: authorizationpolicies.security.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: peerauthentications.security.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: requestauthentications.security.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: telemetries.telemetry.istio.io.istio-system checked successfully
✔ CustomResourceDefinition: istiooperators.install.istio.io.istio-system checked successfully
✔ HorizontalPodAutoscaler: istiod.istio-system checked successfully
✔ ClusterRole: istiod-clusterrole-istio-system.istio-system checked successfully
✔ ClusterRole: istiod-gateway-controller-istio-system.istio-system checked successfully
✔ ClusterRoleBinding: istiod-clusterrole-istio-system.istio-system checked successfully
✔ ClusterRoleBinding: istiod-gateway-controller-istio-system.istio-system checked successfully
✔ ConfigMap: istio.istio-system checked successfully
✔ Deployment: istiod.istio-system checked successfully
✔ ConfigMap: istio-sidecar-injector.istio-system checked successfully
✔ MutatingWebhookConfiguration: istio-sidecar-injector.istio-system checked successfully
✔ PodDisruptionBudget: istiod.istio-system checked successfully
✔ ClusterRole: istio-reader-clusterrole-istio-system.istio-system checked successfully
✔ ClusterRoleBinding: istio-reader-clusterrole-istio-system.istio-system checked successfully
✔ Role: istiod.istio-system checked successfully
✔ RoleBinding: istiod.istio-system checked successfully
✔ Service: istiod.istio-system checked successfully
✔ ServiceAccount: istiod.istio-system checked successfully
✔ EnvoyFilter: stats-filter-1.11.istio-system checked successfully
✔ EnvoyFilter: tcp-stats-filter-1.11.istio-system checked successfully
✔ EnvoyFilter: stats-filter-1.12.istio-system checked successfully
✔ EnvoyFilter: tcp-stats-filter-1.12.istio-system checked successfully
✔ EnvoyFilter: stats-filter-1.13.istio-system checked successfully
✔ EnvoyFilter: tcp-stats-filter-1.13.istio-system checked successfully
✔ ValidatingWebhookConfiguration: istio-validator-istio-system.istio-system checked successfully
✔ HorizontalPodAutoscaler: istio-ingressgateway.istio-system checked successfully
✔ Deployment: istio-ingressgateway.istio-system checked successfully
✔ PodDisruptionBudget: istio-ingressgateway.istio-system checked successfully
✔ Role: istio-ingressgateway-sds.istio-system checked successfully
✔ RoleBinding: istio-ingressgateway-sds.istio-system checked successfully
✔ Service: istio-ingressgateway.istio-system checked successfully
✔ ServiceAccount: istio-ingressgateway-service-account.istio-system checked successfully
Checked 15 custom resource definitions
Checked 2 Istio Deployments
✔ Istio is installed and verified successfully
```
##  Step 8 - Check istio pod status
```shell
kubectl get pod -n istio-system
```
The output looks similar to the following:
```shell
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingressgateway-66ff9c7b6f-f4p6n   1/1     Running   0          16m
istiod-7656645d8c-wrqfq                 1/1     Running   0          21m
```

## Step 9 - Verify Istio version
```shell
istioctl version
```
The output looks similar to the following:
```shell
lient version: 1.13.1
control plane version: 1.13.1
data plane version: 1.13.1 (1 proxies)
```
## Step 9 - Get an overview of your mesh
```shell
istioctl proxy-status
```
The output looks similar to the following:
```shell
NAME                                                   CLUSTER        CDS        LDS        EDS        RDS          ISTIOD                      VERSION
istio-ingressgateway-66ff9c7b6f-f4p6n.istio-system     Kubernetes     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-7656645d8c-wrqfq     1.13.1
``` 
If a proxy is missing from this list it means that it is not currently connected to a Istiod instance so will not be receiving any configuration.   

SYNCED means that Envoy has acknowledged the last configuration Istiod has sent to it.   
NOT SENT means that Istiod hasn’t sent anything to Envoy. This usually is because Istiod has nothing to send.   
STALE means that Istiod has sent an update to Envoy but has not received an acknowledgement. This usually indicates a networking issue between Envoy and Istiod or a bug with Istio itself.   

## Step 10 - Deploy example application on default namespace and inject sidecar
  1. Switch to default namespace
  ```shell
  kns default
  ``` 
  2. Deploy example application on default namespace  
  ```shell
  cd istio-1.13.1
  kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
  ```
  The output looks similar to the following:
  ```shell
  service/details created
  serviceaccount/bookinfo-details created
  deployment.apps/details-v1 created
  service/ratings created
  serviceaccount/bookinfo-ratings created
  deployment.apps/ratings-v1 created
  service/reviews created
  serviceaccount/bookinfo-reviews created
  deployment.apps/reviews-v1 created
  deployment.apps/reviews-v2 created
  deployment.apps/reviews-v3 created
  service/productpage created
  serviceaccount/bookinfo-productpage created
  deployment.apps/productpage-v1 created
  ```
  3. Check status of pod
  ```shell
  kubectl get pod
  ```
  ```shell
  NAME                                    READY   STATUS    RESTARTS   AGE
  ...
  details-v1-5498c86cf5-vgwdw             1/1     Running   0          4m43s
  productpage-v1-65b75f6885-9c2tj         1/1     Running   0          4m43s
  ratings-v1-b477cf6cf-bvrlq              1/1     Running   0          4m43s
  reviews-v1-79d546878f-prctw             1/1     Running   0          4m43s
  reviews-v2-548c57f459-69989             1/1     Running   0          4m43s
  reviews-v3-6dd79655b9-gwp8q             1/1     Running   0          4m43s
  ```

Ref: https://istio.io/latest/docs/ops/diagnostic-tools/proxy-cmd/