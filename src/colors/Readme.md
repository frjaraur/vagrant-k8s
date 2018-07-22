

## Colors Example using frjaraur/colors:1.0




1) Create a deployment
~~~
$ kubectl create -f deployment.yml
~~~
2) Expose deployment to create a new service
~~~
$ kubectl expose --port=8080 --target-port=3000  --name='colors' -f deployment.yml
~~~
3) Check service
~~~
$ kubectl get services
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
colors       ClusterIP   10.98.129.5   <none>        8080/TCP   2m
kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP    22m

$ curl 10.98.129.5:8080
<html>
<head>
    <title>grey</title>
    <meta charset="utf-8" />
    <style>
        body {
            background-color: grey;
        }
......
......
......

$ kubectl describe service colors
Name:              colors
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=colors
Type:              ClusterIP
IP:                10.98.129.5
Port:              <unset>  8080/TCP
TargetPort:        3000/TCP
Endpoints:         192.168.13.65:3000,192.168.200.193:3000
Session Affinity:  None
Events:            <none>
~~~

4) We could use NodePort type instead of using default ClusterIP
~~~
$ kubectl expose --port=8080 --target-port=3000  --name='colors' -f deployment.yml --type NodePort
service "colors" exposed
vagrant@k8s-1:~/src/colors$ kubectl describe service colors
Name:                     colors
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=colors
Type:                     NodePort
IP:                       10.102.199.240
Port:                     <unset>  8080/TCP
TargetPort:               3000/TCP
NodePort:                 <unset>  31761/TCP
Endpoints:                192.168.13.65:3000,192.168.200.193:3000
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
~~~
This way, we can access pur application using node's IPs
~~~
$ curl 10.10.10.11:31761
~~~
5) Using edit mode we cat get created service yml specs
~~~
$ kubectl edit service colors

#
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: 2018-07-22T16:11:05Z
  name: colors
  namespace: default
  resourceVersion: "2635"
  selfLink: /api/v1/namespaces/default/services/colors
  uid: d6224f92-8dc9-11e8-a4b6-080027df3b41
spec:
  clusterIP: 10.102.199.240
  externalTrafficPolicy: Cluster
  ports:
  - nodePort: 31761
    port: 8080
    protocol: TCP
    targetPort: 3000
  selector:
    app: colors
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}

~~~
