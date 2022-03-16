#!/usr/bin/env bash

NS=galaxy
which k
if [[ $? -eq 1 ]] ; then
  alias k=kubectl
fi
P="Waiting for the pods"

function count_pods() {
  return $(k get pods -n $NS | grep 'web\|job\|workflow' | grep Running | wc -l)
}

running=$(count_pods)
while [[ $running -ne 3 ]] ; do
	echo -n $P
	P="."
	sleep 30
	running=$(count_pods)
done
echo
echo "All Galaxy pods are ready"