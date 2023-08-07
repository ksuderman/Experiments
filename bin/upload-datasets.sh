#!/usr/bin/env bash
set -eu

while [[ $# > 0 ]] ; do
	cloud=$1
	shift
	history=$(abm $cloud history create "Human DNA" | jq -r .id)
	echo "Created history $history"
	for size in 1x 10x 30x ; do
		for direction in r f ; do
			key="human-dna-$size-$direction"
			name="human-$size-$direction"						
			echo "Importing $key to $cloud"
			abm $cloud dataset import $key --history $history --name $name
		done
	done
done
