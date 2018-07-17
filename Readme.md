
## Deploying Kubernetes Dashboard:
~~~
- Deploy Dashboard (using NodePort mode)

$ kubectl create -f src/dashboard/kubernetes-dashboard-nodeport.yaml 

- Review deployed pods to obtain node where pod is running

$ kubectl get pods --all-namespaces -o wide

- Review service port

$ kubectl get services --all-namespaces -o wide

- Dashboard should be available at
 https://<node>:<port>

- Get token and then show secret 

$ kubectl describe serviceaccount kubernetes-dashboard -n kube-system

$ kubectl describe secret kubernetes-dashboard-token-cqmb7 -n kube-system

- At this stage we are allowed to login but user has limited access to resources, so we create a ClusterRoleBinding name 'kubernetes-dashboard' with access to cluster resources

$ kubectl create -f dashboard/kubernetes-dashboard-access.yml 

~~~


