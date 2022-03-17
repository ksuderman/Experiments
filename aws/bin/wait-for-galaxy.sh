#!/usr/bin/env bash

NAMESPACE=${NAMESPACE:-galaxy}
which k
if [[ $? -eq 1 ]] ; then
  alias k=kubectl
fi
P="Waiting for the pods"

function is_ready() {
  output=$(k get pods -n $NAMESPACE | grep 'web\|job\|workflow')
  if [[ $($output | wc -l) -ne 3 ]] ; then
    echo 0
    return
  fi
  if [[ $(echo $output | grep Init | wc -l) -gt 0 ]] ; then
    echo 0
    return
  fi
  return 1
}

ready=$(is_ready)
while [[ ready -ne 1 ]] ; do
	echo -n $P
	P="."
	sleep 30
	ready=$(is_ready)
done
echo
echo "All Galaxy pods are ready"