
## Deploying Kubernetes Wordpress Demo:
~~~
- Create a password for Mysql

$ kubectl create secret generic mysql-pass --from-literal=password=PASSWORD

- Review created secret

$ kubectl get secrets

- Create Local Volumes

$ kubectl create -f local-volumes.yaml

- Show Volume claims

$ kubectl get pvc

- Deploy Mysql

$ kubectl create -f mysql-deployment.yaml

- Review Volume claims

$ kubectl get pvc

- Deploy Wordpress

$ kubectl create -f wordpress-deployment.yaml

- Get service type and review deployment host

$ kubectl get services wordpress

$ kubectl get pods -o wide

$ kubectl get services --all-namespaces -o wide

- Show published wordpress

 https://<node>:<port>

~~~
