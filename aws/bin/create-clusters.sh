#!/usr/bin/env bash
set -eu

NAME=suderman
EMAIL=suderman@jhu.edu
PASSWORD=galaxypassword

#INSTANCE_TYPES="c6a c6i m5 m5a m6a m6i r4 r5 r5a"
INSTANCE_TYPES=${@:-"m6a"}
SIZE=4xlarge
#SIZE=8xlarge
#SIZE=12xlarge

if [[ -e ~/.kube/config ]] ; then
	echo "Please delete the global kube config before proceeding."
	exit 1
fi

for type in $INSTANCE_TYPES ; do
	echo "Creating $type cluster"
	bin/cluster create $type $SIZE
	cd ./ansible
	upper=$(echo $type | tr 'a-z' 'A-Z')
	if [[ -e files/values.yml ]] ; then
	  rm files/values.yml
	fi
	cat files/values-template.yml | sed "s/__INSTANCE__/$upper/g" > files/values.yml
	ansible-playbook galaxy-helm.yml
	cd -
	bin/wait-for-galaxy.sh
	abm config create $type ~/.kube/configs/$type
	url=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o json | jq .status.loadBalancer.ingress[0].hostname | sed 's/"//g')
	mv ~/.kube/config ~/.kube/configs/$type
	abm config url $type "http://$url"
	key=$(abm $type user create $NAME $EMAIL $PASSWORD | cut -d\  -f7)
	#key=$(abm $type user key $EMAIL)
	abm config key $type $key
	abm $type workflow upload ../assets/workflows/dna-cloud-costs.ga
	count=3
	while [[ $count > 0 ]] ; do
	  count=$((count - 1))
	  abm $type history import dna
	  state=$(abm $type job ls | head -n 1 | awk '{print $2}')
	  if [[ $state == ok ]] ; then
	    echo "Upload successful"
	  else
	    echo "Upload failed.  Retrying"
	  fi
	done
	abm $type job ls | head -n 1
	echo "Instance $type has been configured"
done