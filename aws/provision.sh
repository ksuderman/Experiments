#!/usr/bin/env bash

function invoke() {
	if [[ -e .ktx ]] ; then
		KUBECONFIG=$(readlink .ktx) $@
	else
		$@
	fi
}

function nfs() {
	invoke helm install nfs-provisioner stable/nfs-server-provisioner \
	--set persistence.enabled=true\
	--set persistence.storageClass="ebs" \
	--set persistence.size="200Gi" \
	--set storageClass.create=true \
	--set storageClass.defaultClass=true \
	--set storageClass.allowVolumeExpansion=true \
	--set storageClass.reclaimPolicy="Delete" \
	--namespace nfs-provisioner \
	--create-namespace
	
	invoke helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system\
    aws-ebs-csi-driver/aws-ebs-csi-driver
}

function cvmfs() {
  invoke helm install cvmfs-csi galaxy/galaxy-cvmfs-csi \
  --set cache.alienCache.enabled=true \
  --set cache.alienCache.storageClass="nfs" \
  --set cache.localCache.enabled=false \
  --namespace cvmfs-csi \
  --create-namespace
}

if [[ $# = 0 ]] ; then
	echo "USAGE: $(basename $0) [cvmfs|nfs]"
	exit 1
fi

while [[ $# > 0 ]] ; do 
	case $1 in
		cvmfs) cvmfs ;;
		nfs) nfs ;;
		*)
			echo "Invalid option $1"
			exit
			;;
	esac
	shift
done
