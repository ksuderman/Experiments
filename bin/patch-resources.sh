#!/usr/bin/env bash

INSTANCES=${INSTANCES:-n1 n2 c2 e2 m5 m5a m5n c6i m6i}
LIMIT=${LIMIT:-128G}
DIR=~/.kube/configs

for i in $INSTANCES ; do
	echo "Patching resource limits on $i to $LIMIT"
	KUBECONFIG=$DIR/$i helm upgrade galaxy -n galaxy galaxy/galaxy \
	--reuse-values \
	--set resources.limits.ephemeral-storage=$LIMIT
done