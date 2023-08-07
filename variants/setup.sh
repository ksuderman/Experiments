#!/usr/bin/env bash

cloud=${1:-gkm}

#namespace=$(kubectl get namespace | grep -v default | grep -v kube | grep Active)
#ip=$(kubectl get svc -n $namespace | grep nginx | awk '{print $4}')
#abm config url $cloud http://$ip:8000/galaxy/

#abm $cloud workflow import variant

#history=$(abm $cloud history create "Input Data" | jq -r .id)
for dataset in forward reverse ; do
	abm $cloud dataset import --history "Input Data" --name $dataset err3485802.$dataset
done
abm $cloud dataset import --history "Input Data" --name genome.genbank genbank