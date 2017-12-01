#!/bin/bash -x

IP=$1

MASTER_IP=$2


#SHARED Between Nodes..
TMPSHARED="/tmp_deploying_stage"
#Docker Multi Daemon

HOME_UBUNTU=/home/ubuntu

# DEFAULTS

#DOCKER_ROOTDIR="${DOCKER_ROOTDIR:=/var/lib/docker}"
#DOCKER_RUNDIR="${DOCKER_RUNDIR:=/var/run}"
#DOCKER_CONFIGDIR="${DOCKER_CONFIGDIR:=/etc/docker}"
#DOCKER_LOGDIR="${DOCKER_LOGDIR:=/var/log/docker}"

ErrorMessage(){
  echo "$(date +%Y/%m/%d-%H:%M:%S) ERROR: $*"
  exit 1
}

InfoMessage(){
  echo "$(date +%Y/%m/%d-%H:%M:%S) INFO: $*"
}


#USER="vagrant"
#[ $(grep -c "${USER}" /etc/passwd) -ne 1 ] && USER="ubuntu"


[ ! -f ${TMPSHARED}/token  -a "${IP}" == "${MASTER_IP}" ] && InfoMessage "Initiating Cluster" \
&& echo $(sudo kubeadm token generate) > ${TMPSHARED}/token \
&& kubeadm init  --token $(cat ${TMPSHARED}/token) --apiserver-advertise-address ${IP}  --service-dns-domain "k8s"  --skip-preflight-checks \
&& mkdir -p $HOME/.kube \
&& mkdir -p $HOME_UBUNTU/.kube \
&& cp -i /etc/kubernetes/admin.conf $HOME/.kube/config \
&& cp -i /etc/kubernetes/admin.conf $HOME_UBUNTU/.kube/config \
&& chown $(id -u):$(id -g) $HOME/.kube/config \
&& chown $(id -u):$(id -g) $HOME_UBUNTU/.kube/config \
&& kubectl apply -f \
https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml \
&&
exit

[ -f ${TMPSHARED}/token ] && InfoMessage "Joining Cluster" \
&& kubeadm join  --token $(cat ${TMPSHARED}/token) ${MASTER_IP}:6443 \
&& exit 
