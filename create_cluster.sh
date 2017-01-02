#!/bin/bash -x

IP=$1

MASTER_IP=$2


#SHARED Between Nodes..
TMPSHARED="/tmp_deploying_stage"
#Docker Multi Daemon

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


[ ! -f ${TMPSHARED}/token ] && InfoMessage "Initiating Cluster" \
&& echo $(sudo kubeadm token generate) > ${TMPSHARED}/token \
&& kubeadm init  --token $(cat ${TMPSHARED}/token) --api-advertise-addresses ${IP} \
&& exit

[ -f ${TMPSHARED}/token ] && InfoMessage "Joining Cluster" \
&& kubeadm join  --token $(cat ${TMPSHARED}/token) ${MASTER_IP}\
&& exit 
