# 🔀 Merge multiple kubeconfig files into one
```shell
export KUBECONFIG=~/.kube/config:/path/to/cluster1.yaml:/path/to/cluster2.yaml
kubectl config view --flatten --merge > ~/.kube/config-merged
mv config-merged config
```
# ✏️ Rename a context
```shell
kubectl config rename-context <old-context-name> <new-context-name>
```
# ❌ Delete a context
```shell
kubectl config delete-context <context-name>
```
