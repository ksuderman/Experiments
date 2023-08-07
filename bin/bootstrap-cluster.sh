#!/usr/bin/env bash

set -eu

if [[ $# != 2 ]] ; then
	echo "USAGE: $0 name URL"
	exit 1
fi

cloud=$1
url=$2
kubeconfig=~/.kube/configs/$cloud

if [[ ! -e $kubeconfig ]] ; then
	echo "Kubeconfig not found: $kubeconfig"
	exit 1
fi

# Create the configuration for a new cluster
abm config new $cloud $kubeconfig
abm config url $cloud $url

# Create the admin user and capture their API key
key=$(abm $cloud user create admin admin@galaxyproject.org galaxypassword | jq -r .key)
abm config key $cloud $key

# Import the workflows
for workflow in hg38 chm13 ; do
	id=$(abm $cloud workflow import $workflow | jq -r .id)
	abm $cloud workflow rename $id "DNA Mapper $workflow"
done

# Create a new history and import the datasets
history=$(abm $cloud history create "Human DNA" | jq -r .id)
for size in 1x 10x 30x ; do
	for direction in r f ; do
		dataset="human-$size-$direction"
		key="human-dna-$size-$direction"
		abm $cloud dataset import --history $history --name $dataset $key
	done
done
