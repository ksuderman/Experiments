#!/usr/bin/env bash

NS=galaxy
which k
P="Waiting for the pods"
running=$(k get pods -n $NS | grep 'web\|job\|workflow' | wc -l)
while [[ $running -gt 3 ]] ; do
	echo -n $P
	P="."
	sleep 30
	running=$(k get pods -n $NS | grep 'web\|job\|workflow' | wc -l)
done
echo
echo "All Galaxy pods are ready"