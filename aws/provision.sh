#!/usr/bin/env bash

# DO NOT USE THIS SCRIPT
#
# Use bin/eks to create/destroy clusters and then run
# the galaxy-helm.yml Ansible playbook to install Galaxy.

function cluster() {
	bin/eks create
}

function cleanup() {
	bin/eks delete
}

function nfs() {
	helm install nfs-provisioner nfs-ganesha/nfs-server-provisioner \
	--set persistence.enabled=true\
	--set persistence.storageClass="ebs" \
	--set persistence.size="200Gi" \
	--set storageClass.create=true \
	--set storageClass.defaultClass=false \
	--set storageClass.allowVolumeExpansion=true \
	--set storageClass.reclaimPolicy="Delete" \
	--namespace nfs-provisioner \
	--create-namespace
	
	kubectl apply -f ansible/files/ebs_storage_class.yml
	helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system aws-ebs-csi-driver/aws-ebs-csi-driver
}

function cvmfs() {
  invoke helm install cvmfs-csi galaxy/galaxy-cvmfs-csi \
  --set cache.alienCache.enabled=true \
  --set cache.alienCache.storageClass="nfs" \
  --set cache.localCache.enabled=false \
  --namespace cvmfs-csi \
  --create-namespace
}

function galaxy() {
	helm install galaxy -n galaxy galaxy/galaxy --create-namespace --values install-values.yml
}

cat <<EOF

!!!THIS SCRIPT HAS BEEN DEPRECATED!!!
Use bin/eks to create and destroy EKS clusters on AWS and then
run the galaxy-helm.yml Ansible playbook to install Galaxy.

EOF

exit 1

if [[ $# = 0 ]] ; then
	echo "USAGE: $(basename $0) [cvmfs|nfs]"
	exit 1
fi

while [[ $# > 0 ]] ; do 
	case $1 in
		cluster|cleanup|nfs|galaxy) 
			$1
		;;
		*)
			echo "Invalid option $1"
			exit
			;;
	esac
	shift
done
