#!/usr/bin/env bash

NAMESPACE=${NAMESPACE:-galaxy}
P="Waiting for the pods"

function is_ready() {
  if [[ $(kubectl get pods -n $NAMESPACE | grep 'web\|job\|workflow' | wc -l) -ne 3 ]] ; then
    echo 0
    return
  fi
  if [[ $(kubectl get pods -n $NAMESPACE | grep 'web\|job\|workflow' | grep Running | grep 1/1 | wc -l) -ne 3 ]] ; then
    echo 0
    return
  fi
  echo 1
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
