#!/bin/bash -x

IP=$1

MASTER_IP=$2

CALICO_URL=$3


#SHARED Between Nodes..
TMPSHARED="/tmp_deploying_stage"
#Docker Multi Daemon


VAGRANT_USER=vagrant
VAGRANT_GROUP=vagrant
HOME_VAGRANT_USER=/home/vagrant

INIT_CLUSTER=0

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


# Calico https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml \

[ ! -f ${TMPSHARED}/token  -a "${IP}" == "${MASTER_IP}" ] && INIT_CLUSTER=1

if [ ${INIT_CLUSTER} -eq 1 ]
then
    InfoMessage "Initiating Cluster" \
    && echo $(sudo kubeadm token generate) > ${TMPSHARED}/token \
    && kubeadm init  --token $(cat ${TMPSHARED}/token) --apiserver-advertise-address ${IP}  \
    --service-dns-domain "k8s"  \
    --pod-network-cidr=192.168.0.0/16 \
    --skip-preflight-checks
fi

mkdir -p $HOME/.kube \
&& mkdir -p $HOME_VAGRANT_USER/.kube \
&& cp -i /etc/kubernetes/admin.conf $HOME/.kube/config \
&& cp -i /etc/kubernetes/admin.conf $HOME_VAGRANT_USER/.kube/config \
&& chown -R $(id -u):$(id -g) $HOME/.kube \
&& chown -R ${VAGRANT_USER}:${VAGRANT_GROUP} $HOME_VAGRANT_USER/.kube

if [ ${INIT_CLUSTER} -eq 1 ] 
then
    #kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
    kubectl apply -f ${CALICO_URL}
    exit
fi

[ -f ${TMPSHARED}/token ] && InfoMessage "Joining Cluster" \
&& kubeadm join  --token $(cat ${TMPSHARED}/token) ${MASTER_IP}:6443 \
--discovery-token-unsafe-skip-ca-verification \
&& exit 
