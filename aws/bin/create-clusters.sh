#!/usr/bin/env bash
set -eu

NAME=suderman
EMAIL=suderman@jhu.edu
PASSWORD=galaxypassword

#INSTANCE_TYPES="c6a c6i m5 m5a m6a m6i r4 r5 r5a"
INSTANCE_TYPES="c5a c6a c6i"

if [[ -e ~/.kube/config ]] ; then
	echo "Please delete the global kube config before proceeding."
	exit 1
fi

for type in $INSTANCE_TYPES ; do
	echo "Created $type cluster"
	bin/cluster create $type 8xlarge
	cd ../assets/ansible
	ansible-playbook galaxy-helm.yml
	cd -
	bin/wait-for-galaxy.sh
	abm config create $type ~/.kube/configs/$type
	url=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o json | jq .status.loadBalancer.ingress[0].hostname | sed 's/"//g')
	mv ~/.kube/config ~/.kube/configs/$type
	abm config url $type $url
	abm $type user create $NAME $EMAIL $PASSWORD
	key=$(abm $type user key $EMAIL)
	abm config key $type $key
	abm $type workflow upload ../assets/workflows/dna-cloud-costs.ga
	abm $type history import dna
	echo "Instance $type has been configured"
done