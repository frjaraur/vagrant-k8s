$ kubectl create -f colors.yml 
$ kubectl get pods
$ kubectl get svc
(example output)
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
blacksvc     ClusterIP   10.98.225.141   <none>        80/TCP    7m
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   40m
whitesvc     ClusterIP   10.109.209.36   <none>        80/TCP    7m

$  curl 10.98.225.141
$  curl 10.109.209.36

$ kubectl create namespace ingress

$ kubectl get namespaces
NAME          STATUS    AGE
default       Active    45m
ingress       Active    7m
kube-public   Active    45m
kube-system   Active    45m

$ kubectl create -f  default-backend.yml -n=ingress

$ kubectl get svc
(example output)
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
blacksvc          ClusterIP   10.98.225.141   <none>        80/TCP    17m
default-backend   ClusterIP   10.110.246.76   <none>        80/TCP    43s
kubernetes        ClusterIP   10.96.0.1       <none>        443/TCP   50m
whitesvc          ClusterIP   10.109.209.36   <none>        80/TCP    17m

$ curl 10.110.246.76
default backend - 404

$ kubectl create -f ingress-controller.yml -n=ingress

